// contracts/base/EthReceiver.sol
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

abstract contract EthReceiver {
    error EthTransferFailed();
    
    receive() external payable {
        if (msg.sender != tx.origin) revert EthTransferFailed();
    }
}