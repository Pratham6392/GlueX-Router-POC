// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


/**
 * @title IPermit
 * @notice A minimal interface for the Permit2 (or similar Permit) contract.
 *         This interface exposes the transferFrom method used for gas-optimized token transfers.
 */
interface IPermit {
    /**
     * @notice Transfers tokens from one address to another using Permit-based approvals.
     * @param from The address from which tokens are transferred.
     * @param to The address receiving the tokens.
     * @param amount The amount of tokens to transfer.
     * @param token The address of the ERC20 token.
     * @return A boolean indicating whether the operation succeeded.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount,
        address token
    ) external returns (bool);
}
