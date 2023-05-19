// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import { IRegistry } from "../interfaces/IERC6551Registry.sol";
import { CookieJar6551Factory } from "./CookieJar6551Summoner.sol";
import { CookieJar6551 } from "./CookieJar6551.sol";

import { AccountERC6551 } from "./ERC6551Module.sol";
import { IAccount } from "../interfaces/IERC6551.sol";
import { MinimalReceiver } from "../lib/MinimalReceiver.sol";

contract CookieNFT is ERC721 {
    using Counters for Counters.Counter;

    address public erc6551Reg;
    address public erc6551Imp;
    address public cookieJarFactory;
    address public cookieJarImp; // list cookie jar

    Counters.Counter private _tokenIdCounter;

    event AccountCreated(
        address account, 
        address indexed cookieJar, 
        uint256 indexed tokenId
        );

    constructor(
        address _erc6551Reg,
        address _erc6551Imp,
        address _cookieJarFactory,
        address _cookieJarImp
    )
        ERC721("CookieJar", "COOKIE")
    {
        erc6551Reg = _erc6551Reg;
        erc6551Imp = _erc6551Imp;
        cookieJarFactory = _cookieJarFactory;
        cookieJarImp = _cookieJarImp;
    }

    function cookieMint(
        address to,
        uint256 periodLength,
        uint256 cookieAmount,
        address cookieToken,
        address[] memory allowList
    )
        public
        returns (address account, address cookieJar, uint256 tokenId)
    {
        tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);


        account = IRegistry(erc6551Reg).createAccount(address(this), tokenId);
        cookieJar = CookieJar6551Factory(cookieJarFactory).summonCookieJar(
            "{\"type\":\"list\", \"title\":\"Cookie NFT\", \"title\":\"Cookie Util NFT\"}",
            cookieJarImp,
            abi.encode(account, periodLength, cookieAmount, cookieToken, allowList)
        );

        CookieJar6551(cookieJar).transferOwnership(account);
        AccountERC6551(payable(account)).setExecutorInit(cookieJar);

        emit AccountCreated(account, cookieJar, tokenId);
    }
}
