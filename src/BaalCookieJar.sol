// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { IBaalToken } from "./interfaces/IBaalToken.sol";
import { IBaal } from "./interfaces/IBaal.sol";
import { CookieJar } from "./CookieJar.sol";

contract BaalCookieJar is CookieJar {

    address public dao;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (
            address _dao, 
            uint256 _cookieAmount
        ) = abi.decode(
                _initializationParams,
                (address, uint256)
            );

        require(_cookieAmount > PERC_POINTS, "amount too low");

        dao = _dao;
        cookieAmount = _cookieAmount;
        posterTag = "daohaus.member.database";


        avatar = IBaal(dao).target();
        target = IBaal(dao).target(); 
    }

    function isAllowList() internal view override returns (bool) {
        return IBaalToken(IBaal(dao).sharesToken()).balanceOf(msg.sender) > 0;
    }

}
