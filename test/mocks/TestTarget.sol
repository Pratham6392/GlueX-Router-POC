// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TestTarget {
    uint256 public counter;

    // A function that increments the counter by the given value.
    function increment(uint256 value) external payable {
        counter += value;
    }
}
