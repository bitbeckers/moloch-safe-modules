// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

interface IHat {
    function balanceOf(address wearer, uint256 hatId) external view returns (uint256 balance);
}


import { CookieJar } from "./CookieJar.sol";

contract HatterJar is CookieJar {
    address public hats;
    uint256 public hatId;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (,,,, address _hats, uint256 _hatId) =
            abi.decode(_initializationParams, (address, uint256, uint256, address, address, uint256));

        hats = _hats;
        hatId = _hatId;
    }

    function isAllowList() internal view override returns (bool) {
        return IHat(hats).balanceOf(msg.sender, hatId) >= 1;
    }
}
