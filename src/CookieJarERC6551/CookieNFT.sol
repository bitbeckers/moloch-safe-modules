// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { IRegistry } from "../interfaces/IERC6551Registry.sol";
import { CookieJar6551Factory } from "./CookieJar6551Summoner.sol";
import { CookieJar6551 } from "./CookieJar6551.sol";

import { Account } from "./ERC6551Module.sol";

contract CookieNFT is ERC721 {
    using Counters for Counters.Counter;

    address public immutable ERC6551REG = 0x1472D0f5c6c151df96352Ec271B8dF1093370A7A;
    address public immutable ERC6551IMP = 0x36963236d915e4e9b5f70677eBD1ea3e69Cfbbd6;
    address public immutable COOKIEJARFACTORY = 0x000000000000cd17345801aa8147b8D3950260FF;
    address public immutable COOKIEJARIMP = 0x000000000000cd17345801aa8147b8D3950260FF; // list cookie jar

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("CookieJar", "COOKIE") { }

    function cookieMint(
        address to,
        uint256 cookieAmount,
        uint256 periodLength,
        address cookieToken,
        address[] memory allowList
    )
        public
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(address(this), tokenId);

        address account =
            IRegistry(ERC6551REG).createAccount(address(this), tokenId);
        address cookieJar = CookieJar6551Factory(COOKIEJARFACTORY).summonCookieJar(
            "{\"type\":\"list\", \"title\":\"Cookie NFT\", \"title\":\"Cookie Util NFT\"}",
            COOKIEJARIMP,
            abi.encode(account, cookieAmount, periodLength, cookieToken, allowList)
        );

        Account(payable(account)).setExecutor(cookieJar);

        CookieJar6551(cookieJar).transferOwnership(account);
        IERC721(address(this)).transferFrom(address(this), to, tokenId);
    }
}
