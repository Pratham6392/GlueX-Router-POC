// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


/**
 * @title IERC20
 * @notice A simplified ERC20 interface.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
        
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
        
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
