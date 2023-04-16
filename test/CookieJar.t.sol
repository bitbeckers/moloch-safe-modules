// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { CookieJar } from "src/CookieJar.sol";
import { TestAvatar } from "@gnosis.pm/zodiac/contracts/test/TestAvatar.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";
import "forge-std/console.sol";

contract CookieJarHarnass is CookieJar {
    function exposed_isAllowList() external returns (bool) {
        return isAllowList();
    }
}

contract CookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal owner = makeAddr("owner");
    address internal molochDAO = vm.addr(666);
    address internal testSafe = vm.addr(1337);

    CookieJarHarnass internal cookieJar;
    ERC20Mintable internal cookieToken = new ERC20Mintable("Mock", "MCK");
    TestAvatar internal testAvatar = new TestAvatar();

    uint256 internal cookieAmount = 2e6;

    string internal reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);
    event Transfer(address from, address to, uint256 amount);

    function setUp() public virtual {
        // uint256 _periodLength,
        // uint256 _cookieAmount,
        // address _cookieToken
        bytes memory initParams = abi.encode(address(testAvatar), 3600, cookieAmount, address(cookieToken));

        cookieJar = new CookieJarHarnass();
        cookieJar.setUp(initParams);

        // Enable module
        testAvatar.enableModule(address(cookieJar));

        //console.log all addresses
        console.log("cookieJar: ", address(cookieJar));
        console.log("cookieToken: ", address(cookieToken));
        console.log("testAvatar: ", address(testAvatar));
        console.log("testSafe: ", address(testSafe));
        console.log("alice: ", address(alice));
        console.log("bob: ", address(bob));
    }

    function testIsEnabledModule() external {
        assertEq(address(testAvatar), cookieJar.avatar());
        assertEq(address(testAvatar), cookieJar.target());
        assertTrue(testAvatar.isModuleEnabled(address(cookieJar)));
    }

    function testIsAllowList() external {
        assertTrue(cookieJar.exposed_isAllowList());
    }

    function testReachInJar() external {
        // No balance so expect fail
        vm.expectRevert(bytes(""));
        cookieJar.reachInJar(reason);

        // Put cookie tokens in jar

        cookieToken.mint(address(testAvatar), cookieAmount * 10 ether);
        cookieToken.mint(address(testSafe), cookieAmount * 10 ether);
        cookieToken.mint(address(cookieJar), cookieAmount * 10 ether);

        // Alice puts her hand in the jar
        vm.startPrank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(testSafe), address(alice), cookieAmount);
        //TODO reachInJar reverts
        cookieJar.reachInJar(reason);
    }
}
