// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();
    error PermitFailed();
    
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        bytes calldata permitData
    ) internal {
        if (permitData.length > 0) {
            (bool success, ) = address(token).call(
                abi.encodeWithSelector(IERC20.permit.selector, permitData)
            );
            if (!success) revert PermitFailed();
        }
        
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) {
            revert SafeTransferFromFailed();
        }
    }

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }

    function safeBalanceOf(IERC20 token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, account)
        );
        return success ? abi.decode(data, (uint256)) : 0;
    }
}