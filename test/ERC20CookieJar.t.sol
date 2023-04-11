// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { IBaal } from "src/interfaces/IBaal.sol";
import { IBaalToken } from "src/interfaces/IBaalToken.sol";
import { ERC20CookieJar } from "src/ERC20CookieJar.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20CookieJarHarnass is ERC20CookieJar {
    function exposed_isAllowList() external view returns (bool) {
        return isAllowList();
    }
}

contract CookieJarTest is PRBTest, StdCheats {
    address alice = vm.addr(1);
    address bob = vm.addr(2);
    address molochDAO = vm.addr(666);
    address testSafe = vm.addr(1337);

    ERC20CookieJarHarnass cookieJar;

    ERC20 sharesToken = new ERC20("Share", "SHR");
    ERC20 mockERC20;

    uint256 cookieAmount = 2e6;
    uint256 threshold = 420;

    string reason = "CookieJar: Testing";

    event Setup(bytes initializationParams);
    event GiveCookie(uint256 amount, uint256 fee);

    function setUp() public virtual {
        mockERC20 = new ERC20("Mock", "MCK");

        //   address _erc20addr,
        //   address _safeTarget,
        //   uint256 _threshold,
        //   uint256 _cookieAmount
        bytes memory initParams = abi.encode(address(mockERC20), testSafe, threshold, cookieAmount);
        cookieJar = new ERC20CookieJarHarnass();
        cookieJar.setUp(initParams);
    }

    function testIdentifyMolochMember() external {
        vm.mockCall(address(mockERC20), abi.encodeWithSelector(ERC20.balanceOf.selector), abi.encode(threshold + 1));
        assertTrue(cookieJar.exposed_isAllowList());
    }
}
