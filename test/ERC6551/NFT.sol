// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { Account } from "src/CookieJarERC6551/ERC6551Module.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";
import { IPoster } from "@daohaus/baal-contracts/contracts/interfaces/IPoster.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { AccountRegistry } from "src/CookieJarERC6551/ERC6551Registry.sol";
import { IRegistry } from "src/interfaces/IERC6551Registry.sol";
import { Account } from "src/CookieJarERC6551/ERC6551Module.sol";
import { MinimalReceiver } from "src/lib/MinimalReceiver.sol";
import { MinimalProxyStore } from "src/lib/MinimalProxyStore.sol";

import { CookieNFT } from "src/CookieJarERC6551/CookieNFT.sol";
import { CookieJar6551 } from "src/CookieJarERC6551/CookieJar6551.sol";
import { CookieJar6551Factory } from "src/CookieJarERC6551/CookieJar6551Summoner.sol";
import { ListCookieJar6551 } from "src/CookieJarERC6551/ListCookieJar6551.sol";

contract AccountRegistryTest is PRBTest {
    Account public implementation;
    AccountRegistry public accountRegistry;

    CookieJar6551 public cookieJarImp;
    CookieJar6551Factory public cookieJarFactory;
    ListCookieJar6551 public listCookieJarImp;
    CookieNFT public tokenCollection;

    event AccountCreated(address account, address indexed tokenContract, uint256 indexed tokenId);

    function setUp() public {
        implementation = new Account();
        accountRegistry = new AccountRegistry(address(implementation));

        cookieJarFactory = new CookieJar6551Factory();
        listCookieJarImp = new ListCookieJar6551();

        tokenCollection = new CookieNFT(
            address(accountRegistry),
            address(implementation),
            address(cookieJarFactory),
            address(listCookieJarImp)
        );
    }

    function testCookieMint() public {
        address user1 = vm.addr(1);
        uint256 cookieAmount = 1e18;
        uint256 periodLength = 3600;
        address cookieToken = address(cookieJarImp);
        address[] memory allowList = new address[](0);

        (address account, address cookieJar, uint256 tokenId) =
            tokenCollection.cookieMint(user1, periodLength, cookieAmount, cookieToken, allowList);

        assertEq(tokenCollection.balanceOf(user1), 1);
    }

    // function testAddAccountToAllowListAsOwner() public {

    // }

    // function testRemoveAccountToAllowListAsOwner() public {

    // }

    // function testAllowListWithdraw() public {

    // }

    // function testNftTransfer() public {

    // }
}
