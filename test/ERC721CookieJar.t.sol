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

contract ERC721CookieJarHarnass is ERC721CookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract CookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal molochDAO = vm.addr(666);
    address internal testSafe = vm.addr(1337);

    ERC721CookieJarHarnass internal cookieJar;

    ERC721 internal gatingERC721 = new ERC721("Gate", "GATE");
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
        // address _erc721Addr,
        // uint256 _threshold,
        bytes memory initParams =
            abi.encode(3600, cookieAmount, address(cookieERC20), address(testSafe), gatingERC721, 1);

        cookieJar = new ERC721CookieJarHarnass();
        cookieJar.setUp(initParams);
    }

    function testIsAllowed() external {
        assertFalse(cookieJar.exposed_isAllowList());

        vm.mockCall(address(gatingERC721), abi.encodeWithSelector(ERC721.balanceOf.selector), abi.encode(true));
        assertTrue(cookieJar.exposed_isAllowList());
    }
}
