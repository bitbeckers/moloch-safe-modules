// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.19 <0.9.0;

import "./Enum.sol";
import "./SignatureDecoder.sol";
import { IBaalToken } from "./interfaces/IBaalToken.sol";
import { IBaal } from "./interfaces/IBaal.sol";

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        external
        returns (bool success);
}

contract AllowanceModule is SignatureDecoder {
    string public constant NAME = "MolochV3 Allowance Module";
    string public constant VERSION = "0.1.0";

    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );

    bytes32 public constant ALLOWANCE_TRANSFER_TYPEHASH =
        0x80b006280932094e7cc965863eb5118dc07e5d272c6670c4a7c87299e04fceeb;
    // keccak256(
    //     "AllowanceTransfer(address safe,address token,uint96 amount,address paymentToken,uint96 payment,uint16
    // nonce)"
    // );

    // Safe -> Token -> Allowance
    mapping(address => mapping(address => Allowance)) public allowances;

    // Safe -> Member -> Token => Spending
    mapping(address => mapping(address => mapping(address => Spending))) public spendings;

    // Safe -> Tokens
    mapping(address => address[]) public tokens;

    // The allowance info is optimized to fit into one word of storage.
    struct Allowance {
        uint96 amount;
        uint16 resetTimeMin; // Maximum reset time span is 65k minutes
        uint32 lastResetMin;
        uint16 nonce;
    }

    // The spending info is optimized to fit into one word of storage.
    struct Spending {
        uint96 spent;
        uint32 lastUpdateMin;
        uint16 nonce;
    }

    event ExecuteAllowanceTransfer(
        address indexed safe, address member, address token, address to, uint96 value, uint16 nonce
    );
    event PayAllowanceTransfer(
        address indexed safe, address member, address paymentToken, address paymentReceiver, uint96 payment
    );
    event SetAllowance(address indexed safe, address token, uint96 allowanceAmount, uint16 resetTime);
    event ResetAllowance(address indexed safe, address token);
    event DeleteAllowance(address indexed safe, address token);

    event ResetSpending(address member, address indexed safe, address token);

    /// @dev View function to check if a delegate is part of a Moloch V3 DAO by checking if they hold the token.
    /// @param molochDAO Moloch V3 DAO address.
    /// @param user Token address.
    /// @return True if delegate is part of the DAO.
    function isMolochMember(address molochDAO, address user) public view returns (bool) {
        address sharesToken = IBaal(molochDAO).sharesToken();
        return IBaalToken(sharesToken).balanceOf(user) > 0;
    }

    /// @dev Allows to update the allowance for a specified token for all members. This can only be done via
    /// a Safe transaction.
    /// @param token Token contract address.
    /// @param allowanceAmount allowance in smallest token unit.
    /// @param resetTimeMin Time after which the allowance should reset
    /// @param resetBaseMin Time based on which the reset time should be increased
    function setAllowance(address token, uint96 allowanceAmount, uint16 resetTimeMin, uint32 resetBaseMin) public {
        Allowance memory allowance = getAllowance(msg.sender, token);
        if (allowance.nonce == 0) {
            // New token
            // Nonce should never be 0 once allowance has been activated
            allowance.nonce = 1;
            tokens[msg.sender].push(token);
        }
        // Divide by 60 to get current time in minutes
        // solium-disable-next-line security/no-block-members
        uint32 currentMin = uint32(block.timestamp / 60);
        if (resetBaseMin > 0) {
            require(resetBaseMin <= currentMin, "resetBaseMin <= currentMin");
            allowance.lastResetMin = currentMin - ((currentMin - resetBaseMin) % resetTimeMin);
        } else if (allowance.lastResetMin == 0) {
            allowance.lastResetMin = currentMin;
        }
        allowance.resetTimeMin = resetTimeMin;
        allowance.amount = allowanceAmount;
        updateAllowance(msg.sender, token, allowance);
        emit SetAllowance(msg.sender, token, allowanceAmount, resetTimeMin);
    }

    function getAllowance(address safe, address token) private view returns (Allowance memory allowance) {
        allowance = allowances[safe][token];
        // solium-disable-next-line security/no-block-members
        uint32 currentMin = uint32(block.timestamp / 60);
        // Check if we should reset the time. We do this on load to minimize storage read/ writes
        if (allowance.resetTimeMin > 0 && allowance.lastResetMin <= currentMin - allowance.resetTimeMin) {
            // Resets happen in regular intervals and `lastResetMin` should be aligned to that
            allowance.lastResetMin = currentMin - ((currentMin - allowance.lastResetMin) % allowance.resetTimeMin);
        }
        return allowance;
    }

    function updateAllowance(address safe, address token, Allowance memory allowance) private {
        allowances[safe][token] = allowance;
    }

    function getSpending(address safe, address member, address token) private view returns (Spending memory spending) {
        spending = spendings[safe][member][token];
        // solium-disable-next-line security/no-block-members
        uint32 currentMin = uint32(block.timestamp / 60);
        // Check if we should reset the time. We do this on load to minimize storage read/ writes
        if (spending.lastUpdateMin <= currentMin - 60) {
            spending.lastUpdateMin = currentMin - ((currentMin - spending.lastUpdateMin) % 60);
        }
        return spending;
    }

    function updateSpending(address safe, address member, address token, Spending memory spending) private {
        spendings[safe][member][token] = spending;
    }

    /// @dev Allows to reset the spending for a specific member and token.
    /// @param member DAO Member whose spending should be updated.
    /// @param token Token contract address.
    function resetSpending(address dao, address member, address token) public {
        require(isMolochMember(dao, member), "!isMolochMember");
        Spending memory spending = getSpending(msg.sender, member, token);
        spending.spent = 0;
        updateSpending(msg.sender, member, token, spending);
        emit ResetSpending(member, msg.sender, token);
    }

    /// @dev Allows to remove the allowance for the tokens of a MolochDAO. This will set all values except the
    /// `nonce` to 0.
    /// @param token Token contract address.
    function deleteAllowance(address token) public {
        Allowance memory allowance = getAllowance(msg.sender, token);
        allowance.amount = 0;
        allowance.resetTimeMin = 0;
        allowance.lastResetMin = 0;
        updateAllowance(msg.sender, token, allowance);
        emit DeleteAllowance(msg.sender, token);
    }

    /// @dev Allows to use the allowance to perform a transfer.
    /// @param member Member address that executes the spend.
    /// @param safe The Safe whose funds should be used.
    /// @param token Token contract address.
    /// @param to Address that should receive the tokens.
    /// @param amount Amount that should be transferred.
    /// @param paymentToken Token that should be used to pay for the execution of the transfer.
    /// @param payment Amount to should be paid for executing the transfer.
    /// @param signature Signature generated by the delegate to authorize the transfer.
    function executeAllowanceTransfer(
        address member,
        GnosisSafe safe,
        address token,
        address payable to,
        uint96 amount,
        address paymentToken,
        uint96 payment,
        bytes memory signature
    )
        public
    {
        // Get current state
        Allowance memory allowance = getAllowance(address(safe), token);
        Spending memory spending = getSpending(address(safe), member, token);
        bytes memory transferHashData =
            generateTransferHashData(address(safe), token, to, amount, paymentToken, payment, allowance.nonce);

        // Update state
        allowance.nonce = allowance.nonce + 1;
        uint96 newSpent = spending.spent + amount;
        // Check new spent amount and overflow
        require(
            newSpent > spending.spent && newSpent <= allowance.amount,
            "newSpent > allowance.spent && newSpent <= allowance.amount"
        );
        spending.spent = newSpent;

        {
            if (payment > 0) {
                // Use updated allowance if token and paymentToken are the same
                Allowance memory paymentAllowance =
                    paymentToken == token ? allowance : getAllowance(address(safe), paymentToken);
                Spending memory paymentSpending =
                    paymentToken == token ? spending : getSpending(address(safe), member, paymentToken);

                newSpent = paymentSpending.spent + payment;
                // Check new spent amount and overflow
                require(
                    newSpent > paymentSpending.spent && newSpent <= paymentAllowance.amount,
                    "newSpent > paymentAllowance.spent && newSpent <= paymentAllowance.amount"
                );
                paymentSpending.spent = newSpent;
                // Update payment allowance if different from allowance
                if (paymentToken != token) {
                    updateAllowance(address(safe), paymentToken, paymentAllowance);
                    updateSpending(address(safe), member, paymentToken, paymentSpending);
                }
            }
        }

        {
            updateAllowance(address(safe), token, allowance);
            updateSpending(address(safe), member, token, spending);

            // Perform external interactions
            // Check signature
            checkSignature(member, signature, transferHashData);
        }

        {
            // TODO add members to events???
            if (payment > 0) {
                // Transfer payment
                // solium-disable-next-line security/no-tx-origin
                transfer(safe, paymentToken, payable(tx.origin), payment);
                // solium-disable-next-line security/no-tx-origin
                emit PayAllowanceTransfer(address(safe), member, paymentToken, tx.origin, payment);
            }

            // Transfer token
            transfer(safe, token, to, amount);
            emit ExecuteAllowanceTransfer(address(safe), member, token, to, amount, allowance.nonce - 1);
        }
    }

    /// @dev Returns the chain id used by this contract.
    function getChainId() public view returns (uint256) {
        uint256 id;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /// @dev Generates the data for the transfer hash (required for signing)
    function generateTransferHashData(
        address safe,
        address token,
        address to,
        uint96 amount,
        address paymentToken,
        uint96 payment,
        uint16 nonce
    )
        private
        view
        returns (bytes memory)
    {
        uint256 chainId = getChainId();
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, chainId, this));
        bytes32 transferHash =
            keccak256(abi.encode(ALLOWANCE_TRANSFER_TYPEHASH, safe, token, to, amount, paymentToken, payment, nonce));
        return abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator, transferHash);
    }

    /// @dev Generates the transfer hash that should be signed to authorize a transfer
    function generateTransferHash(
        address safe,
        address token,
        address to,
        uint96 amount,
        address paymentToken,
        uint96 payment,
        uint16 nonce
    )
        public
        view
        returns (bytes32)
    {
        return keccak256(generateTransferHashData(safe, token, to, amount, paymentToken, payment, nonce));
    }

    function checkSignature(
        address expectedMember,
        bytes memory signature,
        bytes memory transferHashData
    )
        private
        view
    {
        address signer = recoverSignature(signature, transferHashData);
        require(expectedMember == signer, "expectedMember == signer");
    }

    // We use the same format as used for the Safe contract, except that we only support exactly 1 signature and no
    // contract signatures.
    function recoverSignature(
        bytes memory signature,
        bytes memory transferHashData
    )
        private
        view
        returns (address owner)
    {
        // If there is no signature data msg.sender should be used
        if (signature.length == 0) return msg.sender;
        // Check that the provided signature data is as long as 1 encoded ecsda signature
        require(signature.length == 65, "signatures.length == 65");
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = signatureSplit(signature, 0);
        // If v is 0 then it is a contract signature
        if (v == 0) {
            revert("Contract signatures are not supported by this module");
        } else if (v == 1) {
            // If v is 1 we also use msg.sender, this is so that we are compatible to the GnosisSafe signature scheme
            owner = msg.sender;
        } else if (v > 30) {
            // To support eth_sign and similar we adjust v and hash the transferHashData with the Ethereum message
            // prefix before applying ecrecover
            owner = ecrecover(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(transferHashData))),
                v - 4,
                r,
                s
            );
        } else {
            // Use ecrecover with the messageHash for EOA signatures
            owner = ecrecover(keccak256(transferHashData), v, r, s);
        }
        // 0 for the recovered owner indicates that an error happened.
        require(owner != address(0), "owner != address(0)");
    }

    function transfer(GnosisSafe safe, address token, address payable to, uint96 amount) private {
        if (token == address(0)) {
            // solium-disable-next-line security/no-send
            require(
                safe.execTransactionFromModule(to, amount, "", Enum.Operation.Call), "Could not execute ether transfer"
            );
        } else {
            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
            require(
                safe.execTransactionFromModule(token, 0, data, Enum.Operation.Call), "Could not execute token transfer"
            );
        }
    }

    function getTokens(address safe) public view returns (address[] memory) {
        return tokens[safe];
    }

    function getTokenAllowance(address safe, address token) public view returns (uint256[4] memory) {
        Allowance memory allowance = getAllowance(safe, token);
        return [
            uint256(allowance.amount),
            uint256(allowance.resetTimeMin),
            uint256(allowance.lastResetMin),
            uint256(allowance.nonce)
        ];
    }
}
