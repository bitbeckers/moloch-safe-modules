// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { ERC721CookieJar } from "src/ERC721CookieJar.sol";
import { ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";
import { TestAvatar } from "@gnosis.pm/zodiac/contracts/test/TestAvatar.sol";
import { IPoster } from "src/interfaces/IPoster.sol";

contract ERC721CookieJarHarnass is ERC721CookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract ERC721CookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    ERC721CookieJarHarnass internal cookieJar;
    ERC20Mintable internal cookieToken = new ERC20Mintable("Mock", "MCK");
    TestAvatar internal testAvatar = new TestAvatar();

    ERC721 internal gatingERC721 = new ERC721("Gate", "GATE");

    uint256 internal cookieAmount = 2e6;

    string internal reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        // address _safeTarget,
        // uint256 _periodLength,
        // uint256 _cookieAmount,
        // address _cookieToken,
        // address _erc721Addr,
        // uint256 _threshold,
        bytes memory initParams =
            abi.encode(address(testAvatar), 3600, cookieAmount, address(cookieToken), gatingERC721);

        cookieJar = new ERC721CookieJarHarnass();
        cookieJar.setUp(initParams);

        // Enable module
        testAvatar.enableModule(address(cookieJar));

        vm.mockCall(0x000000000000cd17345801aa8147b8D3950260FF, abi.encodeWithSelector(IPoster.post.selector), "");
    }

    function testIsAllowed() external {
        assertFalse(cookieJar.exposed_isAllowList());

        vm.mockCall(address(gatingERC721), abi.encodeWithSelector(ERC721.balanceOf.selector), abi.encode(true));
        assertTrue(cookieJar.exposed_isAllowList());
    }

    function testReachInJar() external {
        // No gating token balance so expect fail
        vm.expectRevert(bytes("not a member"));
        cookieJar.reachInJar(reason);

        // No cookie balance so expect fail
        vm.mockCall(address(gatingERC721), abi.encodeWithSelector(ERC721.balanceOf.selector), abi.encode(1));
        vm.expectRevert(bytes("call failure setup"));
        cookieJar.reachInJar(reason);

        // Put cookie tokens in jar
        cookieToken.mint(address(testAvatar), cookieAmount);

        // Alice puts her hand in the jar
        vm.startPrank(alice);
        vm.expectEmit(false, false, false, true);
        emit GiveCookie(cookieAmount, cookieAmount / 100);
        cookieJar.reachInJar(reason);
    }
}
