// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { ModuleProxyFactory } from "@gnosis.pm/zodiac/contracts/factory/ModuleProxyFactory.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { CookieJarCore } from "src/core/CookieJarCore.sol";

contract CookieJarFactory is Ownable {
    ModuleProxyFactory internal _moduleProxyFactory;

    event SummonCookieJar(address cookieJar, string jarType, bytes initializer);

    /*solhint-disable no-empty-blocks*/
    constructor() { }

    // must be called after deploy to set libraries
    function setProxyFactory(address moduleProxyFactory) public onlyOwner {
        _moduleProxyFactory = ModuleProxyFactory(moduleProxyFactory);
    }

    function summonCookieJar(
        string memory details,
        address singleton,
        bytes memory initializer
    )
        public
        returns (address)
    {
        //TODO CookieJarCore can be an interface?
        CookieJarCore cookieJar = CookieJarCore(Clones.clone(singleton));
        cookieJar.setUp(initializer);

        CookieJarCore(cookieJar).transferOwnership(msg.sender);

        emit SummonCookieJar(address(cookieJar), details, initializer);

        //TODO do we need to return the address?
        return address(cookieJar);
    }

    // todo: use the proxy factory to deploy jars
    function summonCookieJarMod() public returns (address) { }
}
