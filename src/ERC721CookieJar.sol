// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { CookieJar } from "./CookieJar.sol";

contract ERC721CookieJar is CookieJar {

    address public erc721Addr;
    address public safeTarget;

    function setUp(bytes memory _initializationParams, 
        uint256 _cookieAmount, 
        uint256 _periodLength) public override initializer {
        super.setUp(_initializationParams, _cookieAmount, _periodLength);

        (
            address _safeTarget, 
            address _erc721addr
        ) = abi.decode(
                _initializationParams,
                (address, address)
            );

        erc721Addr = _erc721addr;
        safeTarget = _safeTarget;
        posterTag = "cookieJar.erc721";


        avatar = safeTarget;
        target = safeTarget; 
    }

    function isAllowList() internal view override returns (bool) {
        return IERC721(erc721Addr).balanceOf(msg.sender) > 0;
    }

}
