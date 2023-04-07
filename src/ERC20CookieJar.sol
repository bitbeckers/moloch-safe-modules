pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CookieJar } from "./CookieJar.sol";

contract ERC20CookieJar is CookieJar {

    address public erc20Addr;
    address public safeTarget;
    uint256 public threshold;

    function setUp(bytes memory _initializationParams) public override initializer {
        super.setUp(_initializationParams);

        (
            address _erc20addr, 
            address _safeTarget, 
            uint256 _threshold,
            uint256 _cookieAmount
        ) = abi.decode(
                _initializationParams,
                (address, address, uint256, uint256)
            );

        require(_cookieAmount > PERC_POINTS, "amount too low");

        erc20Addr = _erc20addr;
        safeTarget = _safeTarget;
        threshold = _threshold;
        cookieAmount = _cookieAmount;
        posterTag = "cookieJar.erc20";


        avatar = safeTarget;
        target = safeTarget; 
    }

    function isAlloweList() internal view override returns (bool) {
        return IERC20(erc20Addr).balanceOf(msg.sender) > threshold;
    }

}
