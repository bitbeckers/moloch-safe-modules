// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CookieJar } from "./CookieJar.sol";

contract CustomCookieJar is CookieJar {
    address public safeTarget;
    mapping(address allowed => bool exists) public allowList;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (,,, address _safeTarget, address[] memory _allowList) =
            abi.decode(_initializationParams, (uint256, uint256, address, address, address[]));

        safeTarget = _safeTarget;
        posterTag = "cookieJar.custom";

        uint256 length = _allowList.length;

        for (uint256 i = 0; i < length;) {
            allowList[_allowList[i]] = true;

            unchecked {
                ++i;
            }
        }

        avatar = safeTarget;
        target = safeTarget;
    }

    function isAllowList() internal view override returns (bool) {
        return allowList[msg.sender];
    }
}
