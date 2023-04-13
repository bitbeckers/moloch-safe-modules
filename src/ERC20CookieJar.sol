// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CookieJar } from "./CookieJar.sol";

contract ERC20CookieJar is CookieJar {
    address public erc20Addr;
    address public safeTarget;
    uint256 public threshold;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (,,, address _safeTarget, address _erc20addr, uint256 _threshold) =
            abi.decode(_initializationParams, (uint256, uint256, address, address, address, uint256));

        erc20Addr = _erc20addr;
        safeTarget = _safeTarget;
        threshold = _threshold;
        posterTag = "cookieJar.erc20";

        avatar = safeTarget;
        target = safeTarget;
    }

    function isAllowList() internal view override returns (bool) {
        return IERC20(erc20Addr).balanceOf(msg.sender) >= threshold;
    }
}
