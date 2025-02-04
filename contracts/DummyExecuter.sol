// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// You might have an interface IExecutor in your project; here we provide a minimal dummy version.
// Adjust the parameters and function name as needed.
interface IExecutor {
    function executeRoute(
        // Assuming Interaction is defined elsewhere;
        // for a dummy, you can use a placeholder type (or comment this out if not used)
        // For example: Interaction[] calldata interactions,
        // and an IERC20 outputToken parameter.
        // For simplicity, we leave the parameters empty if not needed.
        // If you need a dummy implementation, add the parameters accordingly.
        uint256 dummyParam
    ) external payable;
}

contract DummyExecutor is IExecutor {
    // A dummy implementation that does nothing.
    function executeRoute(uint256 dummyParam) external payable override {
        // Simply do nothing (or add minimal logging if needed).
    }
}
