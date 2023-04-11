// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

import { IPoster } from "./interfaces/IPoster.sol";

abstract contract CookieJar is Module {

    uint256 public PERC_POINTS;
    uint256 public cookieAmount;
    uint256 public sustainabilityFee;
    address public sustainabilityAddress;
    address public posterAddr;
    string public posterTag;

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);
    
    function setUp(bytes memory _initializationParams) public virtual override {
        PERC_POINTS = 1e6;
        posterAddr = 0x000000000000cd17345801aa8147b8D3950260FF;
        sustainabilityAddress = 0x4A9a27d614a74Ee5524909cA27bdBcBB7eD3b315;
        sustainabilityFee = 10000; 
        emit Setup(_initializationParams);
    }

    function reachInJar( string calldata _reason) public {
        require(isAllowList(), "not a member");
        giveCookie(cookieAmount);
        postReason(_reason);
    }

    function giveCookie(uint256 amount) private {
        uint256 fee = (amount / PERC_POINTS) * sustainabilityFee;
        // module exec
        require(
            exec(
                sustainabilityAddress,
                fee,
                bytes(""),
                Enum.Operation.Call
            ),
            "call failure setup"
        );
        require(
            exec(
                msg.sender,
                amount - fee,
                bytes(""),
                Enum.Operation.Call
            ),
            "call failure setup"
        );
        emit GiveCookie(amount, fee);
    }

    function postReason(string calldata _reason) internal virtual {
        IPoster(posterAddr).post(_reason, posterTag);
    }

    function isAllowList() internal virtual returns (bool) {
        return true;
    }

}