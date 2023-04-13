// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar } from "./CookieJar.sol";

contract OpenCookieJar is CookieJar {
    function setUp(bytes memory _initializationParams) public virtual override initializer {
        super.setUp(_initializationParams);

        (,,, address _safeTarget) = abi.decode(_initializationParams, (uint256, uint256, address, address));

        target = _safeTarget;
        posterTag = "cookiejar.open";

        avatar = target;
        target = target;
    }

    function isAllowList() internal pure override returns (bool) {
        return true;
    }
}
