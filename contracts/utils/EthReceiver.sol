// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

abstract contract EthReceiver {
    error EthDepositRejected();
    
    receive() external payable {
        _receive();
    }

    function _receive() internal virtual {
        if (msg.sender == tx.origin) revert EthDepositRejected();
    }
}