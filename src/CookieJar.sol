// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { Module } from "@gnosis.pm/zodiac/contracts/core/Module.sol";
import { Enum } from "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IPoster } from "@daohaus/baal-contracts/contracts/interfaces/IPoster.sol";

abstract contract CookieJar is Module {
    /// @notice The constant that represents percentage points for calculations.
    uint256 public constant PERC_POINTS = 1e6;

    /// @notice The tag used for posts related to this contract.
    string public constant POSTER_TAG = "CookieJar";

    /// @notice The fee charged on each transaction, set at 1% (10,000 out of a million).
    uint256 public constant SUSTAINABILITY_FEE = 10_000;

    /// @notice The address for the poster.
    address public constant POSTER_ADDR = 0x000000000000cd17345801aa8147b8D3950260FF;

    /// @notice The address for the sustainability fee.
    address public constant SUSTAINABILITY_ADDR = 0x4A9a27d614a74Ee5524909cA27bdBcBB7eD3b315;

    /// @notice The amount of "cookie" that can be claimed.
    uint256 public cookieAmount;

    /// @notice The address of the token that is being distributed.
    address public cookieToken;

    /// @notice The length of the period between claims.
    uint256 public periodLength;

    // @notice The claiming address and the timestamp of the last claim.
    mapping(address claimer => uint256 dateTime) public claims;

    /// @dev Emitted when the contract is set up.
    /// @param initializationParams The parameters used for initialization.
    event Setup(bytes initializationParams);

    /// @dev Emitted when a "cookie" is given to an address.
    /// @param cookieMonster The address receiving the cookie.
    /// @param amount The amount of cookie given.
    /// @param fee The fee deducted from the amount.
    event GiveCookie(address indexed cookieMonster, uint256 amount, uint256 fee);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Sets up the contract with the given initialization parameters.
     * @dev The initialization parameters are decoded from a bytes array into the Safe target, period length, cookie
     * amount, and cookie token.
     * The Safe target is set as both the avatar and target for the module.  This means that the module cannot be
     * chained in a series of modules.
     * A check is done to ensure the cookie amount is greater than the percentage points constant.
     * The period length, cookie amount, and cookie token are then set as per the parameters.
     * An event is emitted with the initialization parameters.
     * @param _initializationParams The initialization parameters, encoded as a bytes array.
     */
    function setUp(bytes memory _initializationParams) public virtual override {
        (address _safeTarget, uint256 _periodLength, uint256 _cookieAmount, address _cookieToken) =
            abi.decode(_initializationParams, (address, uint256, uint256, address));

        // Module setup
        avatar = _safeTarget;
        target = _safeTarget;

        // Cookie jar setup
        require(_cookieAmount > PERC_POINTS, "amount too low");
        // require(_cookieAmount % PERC_POINTS == 0, "No crumbs allowed");
        periodLength = _periodLength;
        cookieAmount = _cookieAmount;
        cookieToken = _cookieToken;

        emit Setup(_initializationParams);
    }

    /**
     * @notice Allows a member to make a claim and provides a reason for the claim.
     * @dev Checks if the caller is a member and if the claim period is valid. If the requirements are met,
     * it updates the last claim timestamp for the caller, gives a cookie to the caller, and posts the reason for the
     * claim.
     * This function can only be called by the member themselves, and not on behalf of others.
     * @param _reason The reason provided by the member for making the claim. This will be posted publicly.
     */
    function reachInJar(string calldata _reason) public {
        require(isAllowList(msg.sender), "not a member");
        require(isValidClaimPeriod(msg.sender), "not a valid claim period");

        claims[msg.sender] = block.timestamp;
        giveCookie(msg.sender, cookieAmount);
        postReason(_reason);
    }

    /**
     * @notice Allows a member to make a claim on behalf of another address and provides a reason for the claim.
     * @dev Checks if the caller is a member and if the claim period is valid. If the requirements are met,
     * it updates the last claim timestamp for the caller, gives a cookie to the specified address, and posts the reason
     * for the claim.
     * This function can be called by a member on behalf of another address, allowing for more flexible distribution.
     * @param cookieMonster The address to receive the cookie.
     * @param _reason The reason provided by the member for making the claim. This will be posted publicly.
     */
    function reachInJar(address cookieMonster, string calldata _reason) public {
        require(isAllowList(msg.sender), "not a member");
        require(isValidClaimPeriod(msg.sender), "not a valid claim period");

        claims[msg.sender] = block.timestamp;
        giveCookie(cookieMonster, cookieAmount);
        postReason(_reason);
    }

    /**
     * @notice Transfers the specified amount of cookies to a given address.
     * @dev Calculates the sustainability fee and deducts it from the amount. Then, depending on whether the cookie is
     * an ERC20 token or ether, it executes the transfer operation. Finally, it emits a GiveCookie event.
     * @param cookieMonster The address to receive the cookie.
     * @param amount The amount of cookie to be transferred.
     */
    function giveCookie(address cookieMonster, uint256 amount) private {
        uint256 fee = (amount / PERC_POINTS) * SUSTAINABILITY_FEE;

        // module exec

        if (cookieToken == address(0)) {
            require(exec(SUSTAINABILITY_ADDR, fee, bytes(""), Enum.Operation.Call), "call failure setup");
            require(exec(cookieMonster, amount - fee, bytes(""), Enum.Operation.Call), "call failure setup");
        } else {
            require(
                exec(
                    cookieToken,
                    0,
                    abi.encodeWithSignature("transfer(address,uint256)", abi.encodePacked(SUSTAINABILITY_ADDR, fee)),
                    Enum.Operation.Call
                ),
                "call failure setup"
            );

            require(
                exec(
                    cookieToken,
                    0,
                    abi.encodeWithSignature("transfer(address,uint256)", abi.encodePacked(cookieMonster, amount - fee)),
                    Enum.Operation.Call
                ),
                "call failure setup"
            );
        }
        emit GiveCookie(cookieMonster, amount, fee);
    }

    /**
     * @notice Posts the reason for a claim.
     * @dev Generates a unique identifier (uid) for the post using keccak256. Then, it calls the post function of the
     * Poster contract.
     * @param _reason The reason provided by the member for making the claim.
     */
    function postReason(string calldata _reason) internal {
        bytes32 uid = keccak256(abi.encodePacked(address(this), msg.sender, block.timestamp, _reason));
        IPoster(POSTER_ADDR).post(_reason, string.concat(POSTER_TAG, " ", bytes32ToString(uid)));
    }

    /**
     * @notice Allows a member to assess the reason for a claim.
     * @dev The member can give a thumbs up or thumbs down to a claim reason. The assessment is posted to the Poster
     * contract.
     * @param _uid The unique identifier of the claim reason to be assessed.
     * @param _isGood A boolean indicating whether the assessment is positive (true) or negative (false).
     */
    function assessReason(string calldata _uid, bool _isGood) public {
        require(isAllowList(msg.sender), "not a member");
        string memory tag = string.concat(POSTER_TAG, ".reaction");
        string memory senderString = Strings.toHexString(uint256(uint160(msg.sender)), 20);
        if (_isGood) {
            IPoster(POSTER_ADDR).post(string.concat(_uid, " UP ", senderString), tag);
        } else {
            IPoster(POSTER_ADDR).post(string.concat(_uid, " DOWN ", senderString), tag);
        }
    }

    /**
     * @notice Checks if the caller is eligible to make a claim.
     * @dev Calls the isAllowList and isValidClaimPeriod functions to check if the caller is a member and within the
     * valid claim period.
     * @return allowed A boolean indicating whether the caller is eligible to make a claim.
     */
    function canClaim(address user) public view returns (bool allowed) {
        return isAllowList(user) && isValidClaimPeriod(user);
    }

    /**
     * @notice Checks if the caller is a member.
     * @dev Always returns true in this contract, but is expected to be overridden in a derived contract.
     * @return A boolean indicating whether the caller is a member.
     */
    function isAllowList(address user) internal view virtual returns (bool) {
        return true;
    }

    /**
     * @notice Checks if the claim period for the caller is valid.
     * @dev Returns true if the current time minus the last claim time of the caller is greater than the period length,
     * or if the caller has not made a claim yet (i.e., their last claim time is zero).
     * @return A boolean indicating whether the claim period for the caller is valid.
     */
    function isValidClaimPeriod(address user) internal view returns (bool) {
        return block.timestamp - claims[user] >= periodLength || claims[user] == 0;
    }

    /**
     * @notice Converts a bytes32 value to a string.
     * @dev This is a helper function that is used to convert bytes32 values to strings, for example, to convert hashed
     * values
     * to their string representation.
     * @param _b The bytes32 value to convert.
     * @return The string representation of the given bytes32 value.
     */
    function bytes32ToString(bytes32 _b) private pure returns (string memory) {
        return string(abi.encodePacked(_b));
    }
}
