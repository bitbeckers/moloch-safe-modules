// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar } from "./CookieJar.sol";

contract OpenCookieJar is CookieJar {
    function setUp(bytes memory _initializationParams) public virtual override initializer {
        super.setUp(_initializationParams);

        (address _target, uint256 _cookieAmount) = abi.decode(_initializationParams, (address, uint256));
        require(_cookieAmount > PERC_POINTS, "amount too low");

        target = _target;
        cookieAmount = _cookieAmount;
        posterTag = "cookiejar";

        avatar = target;
        target = target;
    }

    function isAllowList() internal pure override returns (bool) {
        return true;
    }
}
