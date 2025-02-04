// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GluexRouterPOC {
    address public treasury;
    address public nativeToken;

    constructor(address _treasury, address _nativeToken) {
        treasury = _treasury;
        nativeToken = _nativeToken;
    }

    // Only treasury should be able to collect fees.
    function collectFees(address[] calldata tokens, address destination) external {
        require(msg.sender == treasury, "Not treasury");
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                // Transfer the token fee balance to the destination.
                IERC20(tokens[i]).transfer(destination, balance);
            }
        }
    }
}
