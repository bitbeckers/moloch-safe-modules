// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

import { BaalCookieJar } from "./BaalCookieJar.sol";
import { ERC20CookieJar } from "./ERC20CookieJar.sol";
import { OpenCookieJar } from "./OpenCookieJar.sol";

contract CookieJarFactory {

    address public baalCookieJarSingleton;
    address public erc20CookieJarSingleton;
    address public erc721CookieJarSingleton;
    address public openJarSingleton;
    

    event SummonCookieJar(
        address indexed controller,
        address cookieJar,
        bytes jarType,
        uint256 cookieAmount,
        uint256 periodLength,
        address cookieToken
    );

    constructor(
        address _baalCookieJarSingleton, 
        address _openJarSingleton, 
        address _erc20CookieJarSingleton,
        address _erc721CookieJarSingleton) {
        baalCookieJarSingleton = _baalCookieJarSingleton;   
        openJarSingleton = _openJarSingleton;
        erc20CookieJarSingleton = _erc20CookieJarSingleton;
        erc721CookieJarSingleton = _erc721CookieJarSingleton;
    }

    function summonBaalCookieJar(
        address _safeTarget, 
        address _dao,
        uint256 _threshold,
        bool _useShares,
        bool _useLoot,
        uint256 _cookieAmount, 
        uint256 _periodLength,
        address _cookieToken) public {
        bytes memory _initializer = abi.encode(
            _safeTarget,
            _dao,
            _threshold,
            _useShares,
            _useLoot);

        BaalCookieJar _cookieJar = BaalCookieJar(Clones.clone(baalCookieJarSingleton));
        _cookieJar.setUp(_initializer, _cookieAmount, _periodLength, _cookieToken);

        emit SummonCookieJar(
            _dao, 
            address(_cookieJar), 
            bytes("baal"), 
            _cookieAmount, 
            _periodLength, 
            _cookieToken);

    }

    function summonErc20CookieJar(
        address _erc20Addr, 
        address _safeTarget, 
        uint256 _threshold, 
        uint256 _cookieAmount,
        uint256 _periodLength,
        address _cookieToken) public {
        bytes memory _initializer = abi.encode(
            _safeTarget,
            _erc20Addr,
            _threshold);

        ERC20CookieJar _cookieJar = ERC20CookieJar(Clones.clone(erc20CookieJarSingleton));
        _cookieJar.setUp(_initializer, _cookieAmount, _periodLength, _cookieToken);

        emit SummonCookieJar(
            _safeTarget, 
            address(_cookieJar), 
            bytes("erc20"), 
            _cookieAmount, 
            _periodLength, 
            _cookieToken);

    }

    function summonErc721CookieJar(
        address _erc721Addr, 
        address _safeTarget, 
        uint256 _cookieAmount,
        uint256 _periodLength,
        address _cookieToken) public {
        bytes memory _initializer = abi.encode(
            _safeTarget,
            _erc721Addr);

        ERC20CookieJar _cookieJar = ERC721CookieJar(Clones.clone(erc721CookieJarSingleton));
        _cookieJar.setUp(_initializer, _cookieAmount, _periodLength, _cookieToken);

        emit SummonCookieJar(
            _safeTarget, 
            address(_cookieJar), 
            bytes("erc721"), 
            _cookieAmount, 
            _periodLength, 
            _cookieToken);

    }

    function summonCustomCookieJar(
        address _targetSafe, 
        address[] memory _allowedAddresses,
        uint256 _cookieAmount, 
        uint256 _periodLength,
        address _cookieToken) public {
        bytes memory _initializer = abi.encode(_targetSafe, _allowedAddresses);

        OpenCookieJar _cookieJar = OpenCookieJar(Clones.clone(openJarSingleton));
        _cookieJar.setUp(_initializer, _cookieAmount, _periodLength, _cookieToken);

        emit SummonCookieJar(
            _targetSafe, 
            address(_cookieJar), 
            bytes("none"), 
            _cookieAmount, 
            _periodLength, 
            _cookieToken);

    }

    function summonCookieJar(
        address _targetSafe, 
        uint256 _cookieAmount, 
        uint256 _periodLength,
        address _cookieToken) public {
        bytes memory _initializer = abi.encode(_targetSafe);

        OpenCookieJar _cookieJar = OpenCookieJar(Clones.clone(openJarSingleton));
        _cookieJar.setUp(_initializer, _cookieAmount, _periodLength, _cookieToken);

        emit SummonCookieJar(
            _targetSafe, 
            address(_cookieJar), 
            bytes("none"), 
            _cookieAmount, 
            _periodLength, 
            _cookieToken);

    }
}