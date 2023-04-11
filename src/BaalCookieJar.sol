// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { IBaalToken } from "./interfaces/IBaalToken.sol";
import { IBaal } from "./interfaces/IBaal.sol";
import { CookieJar } from "./CookieJar.sol";

contract BaalCookieJar is CookieJar {

    address public dao;
    uint256 public threshold;
    bool public useShares;
    bool public useLoot;

    function setUp(bytes memory _initializationParams, 
        uint256 _cookieAmount, 
        uint256 _periodLength,
        address _cookieToken) public override initializer {
        super.setUp(_initializationParams, _cookieAmount, _periodLength, _cookieToken);

        (
            address _safeTarget, 
            address _dao,
            uint256 _threshold,
            bool _useShares,
            bool _useLoot
        ) = abi.decode(
                _initializationParams,
                (address, address, uint256, bool, bool)
            );

        dao = _dao;
        threshold = _threshold;
        useShares = _useShares;
        useLoot = _useLoot;
        posterTag = "daohaus.member.database";

        // IBaal(dao).target();
        avatar = _safeTarget;
        target = _safeTarget; 
    }

    function isAllowList() internal view override returns (bool) {
        if(useShares && useLoot){
            return IBaalToken(IBaal(dao).sharesToken()).balanceOf(msg.sender) >= threshold ||
                IBaalToken(IBaal(dao).lootToken()).balanceOf(msg.sender) >= threshold;
        }
        if(useLoot){
            return IBaalToken(IBaal(dao).lootToken()).balanceOf(msg.sender) >= threshold;
        }
        return IBaalToken(IBaal(dao).sharesToken()).balanceOf(msg.sender) >= threshold;
    }

}
