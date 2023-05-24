// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar6551 } from "./CookieJar6551.sol";
import { ERC20Allowlist } from "src/core/allowlists/ERC20Allowlist.sol";

contract ERC20CookieJar6551 is ERC20Allowlist, CookieJar6551 {
    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        ERC20Allowlist.setUp(_initializationParams);
    }

    function isAllowList() internal view override returns (bool) {
        return ERC20Allowlist.isAllowList();
    }
}
