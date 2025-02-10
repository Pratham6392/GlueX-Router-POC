// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Interaction} from "../../contracts/RouterStructs.sol";
import {IERC20} from "../../contracts/IERC20.sol";
import {IExecutor} from "../../contracts/IExecuter.sol";


contract DummyExecutor is IExecutor {
    function executeRoute(
        Interaction[] calldata interactions,
        IERC20 
    ) external payable override {
       
        for (uint256 i = 0; i < interactions.length; i++) {
            Interaction calldata inter = interactions[i]; 
            (bool success, bytes memory result) = inter.target.call{value: inter.value}(inter.callData);
            require(success, _getRevertMsg(result));
        }
    }

   
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
          
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }
}
