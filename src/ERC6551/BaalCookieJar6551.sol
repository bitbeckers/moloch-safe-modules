// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar6551 } from "./CookieJar6551.sol";
import { BaalAllowlist } from "src/core/allowlists/BaalAllowlist.sol";

contract BaalCookieJar6551 is BaalAllowlist, CookieJar6551 {
    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        BaalAllowlist.setUp(_initializationParams);
    }

    function isAllowList() internal view override returns (bool) {
        return BaalAllowlist.isAllowList();
    }
}
