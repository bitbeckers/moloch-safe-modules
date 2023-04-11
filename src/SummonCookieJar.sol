// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { BaalCookieJar } from "./BaalCookieJar.sol";
import { ERC20CookieJar } from "./ERC20CookieJar.sol";
import { OpenCookieJar } from "./OpenCookieJar.sol";

contract CookieJarFactory {

    address public baalCookieJarSingleton;
    address public erc20CookieJarSingleton;
    address public openJarSingleton;
    

    event SummonCookieJar(
        address indexed controller,
        address cookieJar,
        bytes jarType,
        uint256 cookieAmount
    );

    constructor(
        address _baalCookieJarSingleton, 
        address _openJarSingleton, 
        address _erc20CookieJarSingleton) {
        baalCookieJarSingleton = _baalCookieJarSingleton;   
        openJarSingleton = _openJarSingleton;
        erc20CookieJarSingleton = _erc20CookieJarSingleton;
    }

    function summonBaalCookieJar(address _dao, uint256 _cookieAmount) public {
        bytes memory _initializer = abi.encode(
            _dao, _cookieAmount);

        BaalCookieJar _cookieJar = BaalCookieJar(Clones.clone(baalCookieJarSingleton));
        _cookieJar.setUp(_initializer);

        emit SummonCookieJar(_dao, address(_cookieJar), bytes("baal"), _cookieAmount);

    }

    function summonErc20CookieJar(
        address _erc20Addr, 
        address _target, 
        uint256 _threshold, 
        uint256 _cookieAmount) public {
        bytes memory _initializer = abi.encode(
            _erc20Addr,
            _target,
            _threshold,
            _cookieAmount);

        ERC20CookieJar _cookieJar = ERC20CookieJar(Clones.clone(erc20CookieJarSingleton));
        _cookieJar.setUp(_initializer);

        emit SummonCookieJar(_target, address(_cookieJar), bytes("none"), _cookieAmount);

    }

    function summonCookieJar(address _target, uint256 _cookieAmount) public {
        bytes memory _initializer = abi.encode(_target, _cookieAmount);

        OpenCookieJar _cookieJar = OpenCookieJar(Clones.clone(openJarSingleton));
        _cookieJar.setUp(_initializer);

        emit SummonCookieJar(_target, address(_cookieJar), bytes("none"), _cookieAmount);

    }
}