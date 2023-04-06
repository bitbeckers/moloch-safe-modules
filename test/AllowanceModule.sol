// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { AllowanceModule } from "src/AllowanceModule.sol";

contract AllowanceModuleTest is PRBTest, StdCheats {
    AllowanceModule module;
    address sharesToken;
    address molochDAO;
    address testUser;

    function setUp() public virtual {
        module = new AllowanceModule();
        sharesToken = address(42);
        molochDAO = address(666);
        testUser = address(69);
    }

    function testIdentifyMolochMember() external {
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.sharesToken.selector), abi.encode(sharesToken));
        vm.mockCall(sharesToken, abi.encodeWithSelector(IBaalToken.balanceOf.selector), abi.encode(10));

        assertEq(IBaalToken(sharesToken).balanceOf(testUser), 10);
        assertTrue(module.isMolochMember(molochDAO, testUser));
    }
}
