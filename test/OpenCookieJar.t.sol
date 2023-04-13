// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { OpenCookieJar } from "src/OpenCookieJar.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";

contract OpenCookieJarHarnass is OpenCookieJar {
    function exposed_isAllowList() external pure returns (bool) {
        return isAllowList();
    }
}

contract OpenCookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal molochDAO = vm.addr(666);
    address internal testSafe = vm.addr(1337);

    OpenCookieJarHarnass internal cookieJar;

    ERC20Mintable internal cookieERC20 = new ERC20Mintable("Mock", "MCK");

    uint256 internal cookieAmount = 2e6;

    string internal reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        // uint256 _periodLength,
        // uint256 _cookieAmount,
        // address _cookieToken,
        // address _safeTarget,
        bytes memory initParams = abi.encode(3600, cookieAmount, address(cookieERC20), address(testSafe));

        cookieJar = new OpenCookieJarHarnass();
        cookieJar.setUp(initParams);
    }

    function testIsAllowList() external {
        //Always true for OpenCookieJar
        assertTrue(cookieJar.exposed_isAllowList());
    }
}
