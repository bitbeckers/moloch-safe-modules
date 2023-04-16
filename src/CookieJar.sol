// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { Module } from "@gnosis.pm/zodiac/contracts/core/Module.sol";
import { Enum } from "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

import { IPoster } from "./interfaces/IPoster.sol";

abstract contract CookieJar is Module {
    uint256 public constant PERC_POINTS = 1e6;
    uint256 public cookieAmount;
    uint256 public sustainabilityFee;
    address public sustainabilityAddress;
    address public posterAddr;
    address public cookieToken;
    string public posterTag;
    uint256 public periodLength;

    mapping(address claimer => uint256 dateTime) public claims;

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp(bytes memory _initializationParams) public virtual override {
        (address _safeTarget, uint256 _periodLength, uint256 _cookieAmount, address _cookieToken) =
            abi.decode(_initializationParams, (address, uint256, uint256, address));

        // Module setup
        avatar = _safeTarget;
        target = _safeTarget;

        // Cookie jar setup
        require(_cookieAmount > PERC_POINTS, "amount too low");
        sustainabilityFee = 10_000; // 1%
        posterAddr = 0x000000000000cd17345801aa8147b8D3950260FF;
        sustainabilityAddress = 0x4A9a27d614a74Ee5524909cA27bdBcBB7eD3b315;
        periodLength = _periodLength;
        cookieAmount = _cookieAmount;
        cookieToken = _cookieToken;

        emit Setup(_initializationParams);
    }

    function reachInJar(string calldata _reason) public {
        require(isAllowList(), "not a member");
        require(isValidClaimPeriod(), "not a valid claim period");

        claims[msg.sender] = block.timestamp;
        giveCookie(cookieAmount);
        postReason(_reason);
    }

    function giveCookie(uint256 amount) private {
        uint256 fee = (amount / percPoints) * sustainabilityFee;
        // module exec

        if (cookieToken == address(0)) {
            require(exec(sustainabilityAddress, fee, bytes(""), Enum.Operation.Call), "call failure setup");
            require(exec(msg.sender, amount - fee, bytes(""), Enum.Operation.Call), "call failure setup");
        } else {
            require(
                exec(
                    cookieToken,
                    0,
                    abi.encodeWithSignature("transfer(address,uint256)", abi.encodePacked(sustainabilityAddress, fee)),
                    Enum.Operation.Call
                ),
                "call failure setup"
            );

            require(
                exec(
                    cookieToken,
                    0,
                    abi.encodeWithSignature("transfer(address,uint256)", abi.encodePacked(msg.sender, amount - fee)),
                    Enum.Operation.Call
                ),
                "call failure setup"
            );
        }
        emit GiveCookie(amount, fee);
    }

    function postReason(string calldata _reason) internal {
        IPoster(posterAddr).post(_reason, posterTag);
    }

    function isAllowList() internal virtual returns (bool) {
        return true;
    }

    function isValidClaimPeriod() private view returns (bool) {
        return block.timestamp - claims[msg.sender] >= periodLength || claims[msg.sender] == 0;
    }
}
