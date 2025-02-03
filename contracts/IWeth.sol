// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}