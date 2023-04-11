// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar } from "./CookieJar.sol";

contract OpenCookieJar is CookieJar {
    function setUp(bytes memory _initializationParams, 
        uint256 _cookieAmount, 
        uint256 _periodLength,
        address _cookieToken) public virtual override initializer {
        super.setUp(_initializationParams, _cookieAmount, _periodLength, _cookieToken);

        (address _safeTarget) = abi.decode(
            _initializationParams, 
            (address));

        target = _safeTarget;
        posterTag = "cookiejar.open";

        avatar = target;
        target = target;
    }

    function isAllowList() internal pure override returns (bool) {
        return true;
    }
}
