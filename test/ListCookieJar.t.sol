// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { ListCookieJar } from "src/ListCookieJar.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";

contract ListCookieJarHarnass is ListCookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract CookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal molochDAO = vm.addr(666);
    address internal testSafe = vm.addr(1337);

    ListCookieJarHarnass internal cookieJar;

    ERC20Mintable internal cookieERC20 = new ERC20Mintable("Mock", "MCK");

    uint256 internal cookieAmount = 2e6;

    string internal reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;

        // address _safeTarget,
        // uint256 _periodLength,
        // uint256 _cookieAmount,
        // address _cookieToken,
        // address[] _allowList,
        bytes memory initParams = abi.encode(3600, cookieAmount, address(cookieERC20), address(testSafe), allowList);

        cookieJar = new ListCookieJarHarnass();
        cookieJar.setUp(initParams);
    }

    function testIsAllowed() external {
        assertFalse(cookieJar.exposed_isAllowList());

        vm.startPrank(alice);
        assertTrue(cookieJar.exposed_isAllowList());
    }
}
