// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";
import { TestAvatar } from "@gnosis.pm/zodiac/contracts/test/TestAvatar.sol";
import { IPoster } from "src/interfaces/IPoster.sol";
import { CookieJarFactory } from "src/SummonCookieJar.sol";
import { BaalCookieJarHarnass } from "test/BaalCookieJar.t.sol";
import { ERC20CookieJarHarnass } from "test/ERC20CookieJar.t.sol";
import { ERC721CookieJarHarnass } from "test/ERC721CookieJar.t.sol";
import { ListCookieJarHarnass } from "test/ListCookieJar.t.sol";
import { OpenCookieJarHarnass } from "test/OpenCookieJar.t.sol";

contract CloneSummoner is Test {
    CookieJarFactory public cookieJarFactory = new CookieJarFactory();
    BaalCookieJarHarnass internal baalCookieJarImplementation = new BaalCookieJarHarnass();
    ERC20CookieJarHarnass internal erc20CookieJarImplementation = new ERC20CookieJarHarnass();
    ERC721CookieJarHarnass internal erc721CookieJarImplementation = new ERC721CookieJarHarnass();
    ListCookieJarHarnass internal listCookieJarImplementation = new ListCookieJarHarnass();
    OpenCookieJarHarnass internal openCookieJarImplementation = new OpenCookieJarHarnass();

    event SummonCookieJar(address cookieJar, string _cookieType);

    function getBaalCookieJar(bytes memory initParams) public returns (BaalCookieJarHarnass) {
        vm.recordLogs();
        cookieJarFactory.summonCookieJar("Baal", address(baalCookieJarImplementation), initParams);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 3);
        assertEq(entries[2].topics[0], keccak256("SummonCookieJar(address,string)"));
        return BaalCookieJarHarnass(abi.decode(entries[2].data, (address)));
    }

    function getERC20CookieJar(bytes memory initParams) public returns (ERC20CookieJarHarnass) {
        vm.recordLogs();
        cookieJarFactory.summonCookieJar("ERC20", address(erc20CookieJarImplementation), initParams);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 3);
        assertEq(entries[2].topics[0], keccak256("SummonCookieJar(address,string)"));
        return ERC20CookieJarHarnass(abi.decode(entries[2].data, (address)));
    }

    function getERC721CookieJar(bytes memory initParams) public returns (ERC721CookieJarHarnass) {
        vm.recordLogs();
        cookieJarFactory.summonCookieJar("ERC721", address(erc721CookieJarImplementation), initParams);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 3);
        assertEq(entries[2].topics[0], keccak256("SummonCookieJar(address,string)"));
        return ERC721CookieJarHarnass(abi.decode(entries[2].data, (address)));
    }

    function getListCookieJar(bytes memory initParams) public returns (ListCookieJarHarnass) {
        vm.recordLogs();
        cookieJarFactory.summonCookieJar("List", address(listCookieJarImplementation), initParams);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 3);
        assertEq(entries[2].topics[0], keccak256("SummonCookieJar(address,string)"));
        return ListCookieJarHarnass(abi.decode(entries[2].data, (address)));
    }

    function getOpenCookieJar(bytes memory initParams) public returns (OpenCookieJarHarnass) {
        vm.recordLogs();
        cookieJarFactory.summonCookieJar("Open", address(openCookieJarImplementation), initParams);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 3);
        assertEq(entries[2].topics[0], keccak256("SummonCookieJar(address,string)"));
        return OpenCookieJarHarnass(abi.decode(entries[2].data, (address)));
    }
}
