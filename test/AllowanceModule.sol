// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { AllowanceModule, GnosisSafe } from "src/AllowanceModule.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SigUtils } from "src/utils/SigUtils.sol";

contract AllowanceModuleTest is PRBTest, StdCheats {
    address alice = vm.addr(1);
    address bob = vm.addr(2);
    address molochDAO = vm.addr(666);
    address testSafe = vm.addr(1337);

    AllowanceModule module;

    ERC20 sharesToken = new ERC20("Share", "SHR");
    ERC20 mockERC20;

    SigUtils sigUtils;

    event SetAllowance(address indexed safe, address token, uint96 allowanceAmount, uint16 resetTime);

    function setUp() public virtual {
        module = new AllowanceModule();
        mockERC20 = new ERC20("Mock", "MCK");
        sigUtils = new SigUtils(module.DOMAIN_SEPARATOR_TYPEHASH());
    }

    function testIdentifyMolochMember() external {
        vm.mockCall(molochDAO, abi.encodeWithSelector(IBaal.sharesToken.selector), abi.encode(sharesToken));
        vm.mockCall(address(sharesToken), abi.encodeWithSelector(IBaalToken.balanceOf.selector), abi.encode(10));

        assertEq(IBaalToken(address(sharesToken)).balanceOf(alice), 10);
        assertTrue(module.isMolochMember(molochDAO, alice));
    }

    function testSettingAllowance() external {
        startHoax(testSafe, 10 ether);
        uint96 allowanceAmount = 10_000_000;
        uint16 resetTime = 3600;

        vm.expectEmit(true, true, true, true);
        emit SetAllowance(testSafe, address(mockERC20), allowanceAmount, resetTime);

        module.setAllowance(address(mockERC20), allowanceAmount, resetTime, resetTime);

        //TODO test lastResetMin
        (
            uint96 amount,
            uint16 resetTimeMin, // Maximum reset time span is 65k minutes
            ,
            uint16 nonce
        ) = module.allowances(testSafe, address(mockERC20));

        assertEq(amount, allowanceAmount);
        assertEq(resetTimeMin, resetTime);
        assertEq(nonce, 1);

        assertEq(module.getTokens(testSafe).length, 1);
        assertEq(module.getTokens(testSafe)[0], address(mockERC20));
    }

    function testSpendingAllowance() external {
        startHoax(testSafe, 10 ether);
        uint96 allowanceAmount = 10_000_000;
        uint96 transferAmount = allowanceAmount / 2;

        uint16 resetTime = 3600;
        module.setAllowance(address(mockERC20), allowanceAmount, resetTime, resetTime);

        SigUtils.AllowanceTransfer memory allowanceTransfer =
            SigUtils.AllowanceTransfer(testSafe, address(mockERC20), transferAmount, address(mockERC20), 0, 1);


        // TOFIX: execution with signed message
        bytes32 digest = sigUtils.getTypedDataHash(allowanceTransfer);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1337, digest); // spender signs owner's approval

        module.executeAllowanceTransfer(
            alice,
            GnosisSafe(testSafe),
            address(mockERC20),
            payable(bob),
            transferAmount,
            address(mockERC20),
            0,
            abi.encodePacked(r, s, v)
        );
    }
}
