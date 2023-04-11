// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CookieJar } from "./CookieJar.sol";

contract ERC20CookieJar is CookieJar {

    address public safeTarget;
    mapping(address allowed => bool exists) public allowList;

    function setUp(bytes memory _initializationParams, 
        uint256 _cookieAmount, 
        uint256 _periodLength) public override initializer {
        super.setUp(_initializationParams, _cookieAmount, _periodLength);

        (
            address _safeTarget, 
            address[] memory _allowList
        ) = abi.decode(
                _initializationParams,
                (address, address[])
            );

        erc20Addr = _erc20addr;
        safeTarget = _safeTarget;
        posterTag = "cookieJar.custom";

        for(uint256 i = 0; i < _allowList.length; i++){
            allowList[_allowList[i]] = true;
        }

        avatar = safeTarget;
        target = safeTarget; 
    }

    function isAllowList() internal view override returns (bool) {
        return allowList[msg.sender];
    }

}
