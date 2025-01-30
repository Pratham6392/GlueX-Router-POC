// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../interfaces/IERC20.sol";
import {RevertReasonForwarder} from "./RevertReasonForwarder.sol";

library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();
    
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );
        
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFromFailed();
        }
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFailed();
        }
    }

    function safeBalanceOf(IERC20 token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, account)
        );
        require(success, "Balance check failed");
        return abi.decode(data, (uint256));
    }
}