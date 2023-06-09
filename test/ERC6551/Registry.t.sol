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

contract AccountRegistryTest is PRBTest {
    Account implementation;
    AccountRegistry public accountRegistry;

    event AccountCreated(address account, address indexed tokenContract, uint256 indexed tokenId);

    function setUp() public {
        implementation = new Account();
        accountRegistry = new AccountRegistry(address(implementation));
    }

    function testDeployAccount(address tokenCollection, uint256 tokenId) public {
        assertTrue(address(accountRegistry) != address(0));

        address predictedAccountAddress = accountRegistry.account(tokenCollection, tokenId);

        vm.expectEmit(true, true, true, true);
        emit AccountCreated(predictedAccountAddress, tokenCollection, tokenId);
        address accountAddress = accountRegistry.createAccount(tokenCollection, tokenId);

        assertTrue(accountAddress != address(0));
        assertTrue(accountAddress == predictedAccountAddress);
        assertEq(MinimalProxyStore.getContext(accountAddress), abi.encode(block.chainid, tokenCollection, tokenId));
    }
}
