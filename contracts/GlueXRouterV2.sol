// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./EthReceiver.sol";
import {Interaction} from "./base/RouterStructs.sol";
import {IExecutor} from "./interfaces/IExecutor.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SafeERC20} from "./lib/SafeERC20.sol";

contract GlueXRouter is EthReceiver {
    using SafeERC20 for IERC20;

    // Custom errors
    error DeadlineExpired();
    error InvalidAmount();
    error InvalidReceiver();
    error InvalidFeeConfiguration();
    error InsufficientOutput();

    // Events
    event RouteExecuted(
        bytes32 indexed routeId,
        address indexed user,
        IERC20 inputToken,
        IERC20 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 totalFee
    );

    struct RouteParams {
        IERC20 inputToken;
        IERC20 outputToken;
        uint256 inputAmount;
        uint256 minOutputAmount;
        uint256 deadline;
        bytes32 routeId;
        bytes permitData;
    }

    address public immutable feeCollector;
    address public immutable WETH;
    uint256 public constant MAX_FEE_BPS = 50; // 0.5%
    uint256 public feeBps;

    constructor(address _feeCollector, address _WETH) {
        feeCollector = _feeCollector;
        WETH = _WETH;
    }

    function executeRoute(
        IExecutor executor,
        RouteParams calldata params,
        Interaction[] calldata interactions
    ) external payable {
        // Validate deadline
        if (block.timestamp > params.deadline) revert DeadlineExpired();

        // Handle token input
        if (address(params.inputToken) == WETH && msg.value > 0) {
            require(msg.value == params.inputAmount, "Value mismatch");
        } else {
            params.inputToken.safeTransferFrom(
                msg.sender,
                address(this),
                params.inputAmount,
                params.permitData
            );
        }

        // Execute interactions
        uint256 balanceBefore = params.outputToken.safeBalanceOf(address(this));
        executor.execute{value: msg.value}(interactions);
        uint256 balanceAfter = params.outputToken.safeBalanceOf(address(this));

        // Calculate output
        uint256 outputAmount = balanceAfter - balanceBefore;
        uint256 fee = (outputAmount * feeBps) / 10_000;
        uint256 finalAmount = outputAmount - fee;

        // Validate output
        if (finalAmount < params.minOutputAmount) revert InsufficientOutput();
        if (fee > 0) {
            params.outputToken.safeTransfer(feeCollector, fee);
        }

        // Transfer to sender
        params.outputToken.safeTransfer(msg.sender, finalAmount);

        emit RouteExecuted(
            params.routeId,
            msg.sender,
            params.inputToken,
            params.outputToken,
            params.inputAmount,
            finalAmount,
            fee
        );
    }

    // Administration functions
    function setFee(uint256 newFeeBps) external {
        require(msg.sender == feeCollector, "Unauthorized");
        require(newFeeBps <= MAX_FEE_BPS, "Fee too high");
        feeBps = newFeeBps;
    }

    // Emergency recovery
    function recoverToken(IERC20 token, uint256 amount) external {
        require(msg.sender == feeCollector, "Unauthorized");
        token.safeTransfer(feeCollector, amount);
    }

    receive() external payable override {
        require(msg.sender == WETH, "Direct ETH deposit");
    }
}
