// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { CookieJar } from "./CookieJar.sol";

contract CookieJarModuleSummoner is Ownable {
    ModuleProxyFactory internal moduleProxyFactory;

    event SummonCookieJar(address cookieJar, string jarType, bytes initializer);

    /*solhint-disable no-empty-blocks*/
    constructor() Ownable() { }

    // must be called after deploy to set libraries
    function setAddrs(address _moduleProxyFactory) public onlyOwner {
        moduleProxyFactory = ModuleProxyFactory(_moduleProxyFactory);
    }

    /*
        BaalCookieJar
        bytes memory _initializer = abi.encode(
            _safeTarget,
            uint256 _cookieAmount, 
            uint256 _periodLength,
            address _cookieToken,
            _dao,
            _threshold,
            _useShares,
            _useLoot);
        Erc20CookieJar
        bytes memory _initializer = abi.encode(
            _safeTarget,
            uint256 _cookieAmount, 
            uint256 _periodLength,
            address _cookieToken,
            _erc20Addr,
            _threshold);
        Erc721
        bytes memory _initializer = abi.encode(
            _safeTarget,
            uint256 _cookieAmount, 
            uint256 _periodLength,
            address _cookieToken,
            _erc721Addr);
        listCookieJar
        bytes memory _initializer = abi.encode(
            _safeTarget, 
            uint256 _cookieAmount, 
            uint256 _periodLength,
            address _cookieToken,
            _allowedAddresses);
        OpenCookieJar
        bytes memory _initializer = abi.encode(
            _safeTarget,
            uint256 _cookieAmount, 
            uint256 _periodLength,
            address _cookieToken,);
    */

    /*
        // example encode
        // open jar
        var abiCoder = ethers.utils.defaultAbiCoder;
        abiCoder.encode(["address","uint256","uint256","address"],
        ["0x4A9a27d614a74Ee5524909cA27bdBcBB7eD3b315",
        "100000000000000000",
        "3600",
        "0x4A9a27d614a74Ee5524909cA27bdBcBB7eD3b315"])
    */

    function summonCookieJar(
        address _singleton,
        bytes memory _initializer,
        string memory _details,
        uint256 _saltNonce
    )
        public
    {
        CookieJar _cookieJar = CookieJar(moduleProxyFactory.deployModule(_singleton, _initializer, _saltNonce));

        emit SummonCookieJar(address(_cookieJar), _details, _initializer);
    }
}
