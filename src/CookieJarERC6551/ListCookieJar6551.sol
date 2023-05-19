// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.19;

import { CookieJar6551 } from "./CookieJar6551.sol";

contract ListCookieJar6551 is CookieJar6551 {
    address public safeTarget;
    mapping(address allowed => bool isAllowed) public allowList;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (,,,, address[] memory _allowList) =
            abi.decode(_initializationParams, (address, uint256, uint256, address, address[]));

        for (uint256 i = 0; i < _allowList.length; i++) {
            allowList[_allowList[i]] = true;
        }
    }

    function isAllowList() internal view override returns (bool) {
        return allowList[msg.sender];
    }

    function setAllowList(address _address, bool _isAllowed) external onlyOwner {
        allowList[_address] = _isAllowed;
    }
}
