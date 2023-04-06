// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // "AllowanceTransfer(
    // address safe,
    // address token,
    // uint96 amount,
    // address paymentToken,
    // uint96 payment,
    // uint16 nonce)"
    bytes32 public constant ALLOWANCE_TRANSFER_TYPEHASH =
        0x80b006280932094e7cc965863eb5118dc07e5d272c6670c4a7c87299e04fceeb;

    struct AllowanceTransfer {
        address safe;
        address token;
        uint96 amount;
        address paymentToken;
        uint96 payment;
        uint16 nonce;
    }

    // computes the hash of an allowanceTransfer
    function getStructHash(AllowanceTransfer memory _allowanceTransfer) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                ALLOWANCE_TRANSFER_TYPEHASH,
                _allowanceTransfer.safe,
                _allowanceTransfer.token,
                _allowanceTransfer.amount,
                _allowanceTransfer.paymentToken,
                _allowanceTransfer.payment,
                _allowanceTransfer.nonce
            )
        );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(AllowanceTransfer memory _allowanceTransfer) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_allowanceTransfer)));
    }

    // computes the signature message for the domain, which can be used to recover the signer
    function getSignature(AllowanceTransfer memory _allowanceTransfer) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_allowanceTransfer)));
    }
}
