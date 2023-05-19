// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";

import { CookieJar6551Factory } from "../src/CookieJarERC6551/CookieJar6551Summoner.sol";
import { ListCookieJar6551 } from "../src/CookieJarERC6551/ListCookieJar6551.sol";
import { CookieNFT } from "../src/CookieJarERC6551/CookieNFT.sol";

import { AccountERC6551 } from "../src/CookieJarERC6551/ERC6551Module.sol";
import { AccountRegistry } from "../src/CookieJarERC6551/ERC6551Registry.sol";


import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";

//import forge console
import { console } from "forge-std/console.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployCookieJar6551 is Script {
    address internal deployer;

    address internal listCookieJar;

    address internal summonCookieJar;
    address internal accountImp;
    address internal registry;
    address internal nft;

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);

        listCookieJar = address(new ListCookieJar6551());

        summonCookieJar = address(new CookieJar6551Factory());

        
        accountImp = address(new AccountERC6551());
        registry = address(new AccountRegistry(accountImp));

        nft = address(new CookieNFT(
            registry, // account registry
            accountImp,
            summonCookieJar,
            listCookieJar
        ));
        // solhint-disable quotes

        console.log('"listCookieJar imp": "%s",', listCookieJar);
        console.log('"summonCookieJar": "%s",', summonCookieJar);
        console.log('"account Imp": "%s",', accountImp);
        console.log('"nft": "%s",', nft);

        // solhint-enable quotes

        vm.stopBroadcast();
    }
}
