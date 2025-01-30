// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "../base/RouterStructs.sol";

interface IExecutor {
    function execute(Interaction[] calldata interactions) external payable;
}