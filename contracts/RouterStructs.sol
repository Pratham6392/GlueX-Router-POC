// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

    struct Interaction {
        address target;
        uint256 value;
        bytes callData;
    }

