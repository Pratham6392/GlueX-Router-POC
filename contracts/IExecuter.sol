// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


import {Interaction} from "./RouterStructs.sol";
import {IERC20} from "./IERC20.sol";

/**
 * @title IExecutor
 * @notice Interface for the executor contract which performs the route's interactions.
 */
interface IExecutor {
    /**
     * @notice Executes a series of interactions.
     * @param interactions An array of Interaction structs to execute.
     * @param outputToken The ERC20 token expected as output.
     */
    function executeRoute(
        Interaction[] calldata interactions,
        IERC20 outputToken
    ) external payable;
}
