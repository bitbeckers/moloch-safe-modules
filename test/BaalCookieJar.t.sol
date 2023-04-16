// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { BaalCookieJar } from "src/BaalCookieJar.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { ERC20Mintable } from "test/utils/ERC20Mintable.sol";

contract BaalCookieJarHarnass is BaalCookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract BaalCookieJarTest is PRBTest, StdCheats {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal molochDAO = vm.addr(666);
    address internal testSafe = vm.addr(1337);

    BaalCookieJarHarnass internal cookieJar;

    ERC20 internal sharesToken = new ERC20("Share", "SHR");
    ERC20Mintable internal cookieERC20 = new ERC20Mintable("Mock", "MCK");

    uint256 internal cookieAmount = 2e6;

    string internal reason = "BaalCookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.sharesToken.selector), abi.encode(sharesToken));
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.target.selector), abi.encode(sharesToken));

        // uint256 _periodLength,
        // uint256 _cookieAmount,
        // address _cookieToken,
        // address _safeTarget,
        // address _dao,
        // uint256 _threshold,
        // bool _useShares,
        // bool _useLoot
        bytes memory initParams =
            abi.encode(address(testSafe), 3600, cookieAmount, address(cookieERC20), molochDAO, 1, true, true);

        cookieJar = new BaalCookieJarHarnass();
        cookieJar.setUp(initParams);
    }

    function testIdentifyMolochMember() external {
        vm.mockCall(address(sharesToken), abi.encodeWithSelector(IBaalToken.balanceOf.selector), abi.encode(1));
        assertTrue(cookieJar.exposed_isAllowList());
    }
}
