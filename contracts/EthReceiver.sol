// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;


abstract contract EthReceiver {
    error EthDepositRejected();
    
    receive() external payable virtual{
        _receive();
    }

    function _receive() internal virtual {
        if (msg.sender == tx.origin) revert EthDepositRejected();
    }
}