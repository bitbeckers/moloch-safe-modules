// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { ERC20Allowlist } from "src/core/allowlists/ERC20Allowlist.sol";
import { ZodiacCookieJar } from "src/SafeModule/ZodiacCookieJar.sol";

contract ZodiacERC20CookieJar is ERC20CookieJar, ZodiacCookieJar {
    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        ERC20CookieJar.setUp(_initializationParams);
    }

    function isAllowList(address user) internal view override returns (bool) {
        return ERC20CookieJar.isAllowList(user);
    }
}
