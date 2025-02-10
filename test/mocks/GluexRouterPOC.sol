// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IExecutor} from "../../contracts/IExecuter.sol";
import {Interaction} from "../../contracts/RouterStructs.sol";

contract GluexRouterPOC {
    using SafeERC20 for IERC20;

    address public treasury;
    address public nativeToken;
    uint256 public feeBps;                     // Fee in basis points
    uint256 public constant MAX_FEE_BPS = 50;    // Maximum fee is 50 bps (0.5%)

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

    constructor(address _treasury, address _nativeToken) {
        treasury = _treasury;
        nativeToken = _nativeToken;
    }

    function collectFees(address[] calldata tokens, address destination) external {
        require(msg.sender == treasury, "Not treasury");
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                IERC20(tokens[i]).transfer(destination, balance);
            }
        }
    }

    function executeRoute(
        IExecutor executor,
        RouteParams calldata params,
        Interaction[] calldata interactions
    ) external payable {
        require(block.timestamp <= params.deadline, "Deadline expired");

        // Handle token input: if input token equals nativeToken, expect ETH sent; else pull tokens.
        if (address(params.inputToken) == nativeToken && msg.value > 0) {
            require(msg.value == params.inputAmount, "Value mismatch");
        } else {
            params.inputToken.safeTransferFrom(
                msg.sender,
                address(this),
                params.inputAmount
            );
        }

       // Execute interactions
        IERC20 outputToken = params.outputToken;
        uint256 balanceBefore = outputToken.balanceOf(address(this));
       executor.executeRoute{value: msg.value}(interactions, outputToken);
        uint256 balanceAfter = outputToken.balanceOf(address(this));

        uint256 outputAmount = balanceAfter - balanceBefore;
        uint256 fee = (outputAmount * feeBps) / 10_000;
        uint256 finalAmount = outputAmount - fee;

        require(finalAmount >= params.minOutputAmount, "Insufficient output");

        if (fee > 0) {
            params.outputToken.safeTransfer(treasury, fee);
        }
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

    function setFee(uint256 newFeeBps) external {
        require(msg.sender == treasury, "Not treasury");
        require(newFeeBps <= MAX_FEE_BPS, "Fee too high");
        feeBps = newFeeBps;
    }

    receive() external payable {
        require(msg.sender == nativeToken, "Direct ETH deposit not allowed");
    }
}
