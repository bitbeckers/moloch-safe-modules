// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { BaalCookieJar } from "src/BaalCookieJar.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract BaalCookieJarHarnass is BaalCookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract BaalCookieJarTest is PRBTest, StdCheats {
    address alice = vm.addr(1);
    address bob = vm.addr(2);
    address molochDAO = vm.addr(666);
    address testSafe = vm.addr(1337);

    BaalCookieJarHarnass cookieJar;

    ERC20 sharesToken = new ERC20("Share", "SHR");
    ERC20 mockERC20;

    uint256 cookieAmount = 2e6;

    string reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.sharesToken.selector), abi.encode(sharesToken));
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.target.selector), abi.encode(sharesToken));

        bytes memory initParams = abi.encode(molochDAO, cookieAmount);

        cookieJar = new BaalCookieJarHarnass();
        cookieJar.setUp(initParams);

        mockERC20 = new ERC20("Mock", "MCK");
    }

    function testIdentifyMolochMember() external {
        vm.mockCall(address(sharesToken), abi.encodeWithSelector(IBaalToken.balanceOf.selector), abi.encode(1));
        assertTrue(cookieJar.exposed_isAllowList());
    }
}