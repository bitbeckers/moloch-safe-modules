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



contract RegistryTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal molochDAO = vm.addr(666);

    Account implementation;
    AccountRegistry public accountRegistry;

    ERC20Mintable internal cookieToken = new ERC20Mintable("Mock", "MCK");

    event Setup(bytes initializationParams);


    function setUp() public virtual {

        // implementation = new Account();
        // accountRegistry = new AccountRegistry(address(implementation));
    }
}
