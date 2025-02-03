// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


import {IERC20} from "./IERC20.sol";

/**
 * @title SafeERC20
 * @notice Library for safe ERC20 operations with added support for Permit2 transfers.
 */
library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();

    // Example Permit2 address. Replace with the actual Permit2 contract address on your network.
    address private constant _PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    uint256 private constant _RAW_CALL_GAS_LIMIT = 5000;

    /**
     * @notice Transfers tokens from `from` to `to` using either the standard transferFrom or Permit2.
     * @param token The ERC20 token.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The token amount to transfer.
     * @param permit2 If true, uses the Permit2 method.
     */
    function safeTransferFromUniversal(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        bool permit2
    ) internal {
        if (permit2) {
            safeTransferFromPermit2(token, from, to, amount);
        } else {
            safeTransferFrom(token, from, to, amount);
        }
    }

    /**
     * @notice Performs a standard ERC20 transferFrom.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(token.transferFrom.selector, from, to, amount)
        );
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFromFailed();
        }
    }

    /**
     * @notice Uses the Permit2 contract to transfer tokens for gas-optimized operations.
     * @dev This implementation assumes the Permit2 contract exposes a function:
     *      transferFrom(address from, address to, uint256 amount, address token)
     */
    function safeTransferFromPermit2(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = _PERMIT2.call{gas: _RAW_CALL_GAS_LIMIT}(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256,address)",
                from,
                to,
                amount,
                address(token)
            )
        );
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFromFailed();
        }
    }

    /**
     * @notice Safely transfers tokens using the ERC20 transfer function.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(token.transfer.selector, to, amount)
        );
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFailed();
        }
    }
}
