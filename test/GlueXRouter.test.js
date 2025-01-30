// GlueXRouterV2 Test Suite
// Tests core functionality of the GlueX Router contract using Hardhat

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseEther } = ethers.utils;

describe("GlueXRouterV2 Contract Tests", function() {
  let router, executor;
  let owner, treasury, user;
  
  // Common test parameters
  const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const TEST_AMOUNT = parseEther("100");
  const MIN_OUTPUT = parseEther("0.9");
  const FEE_BPS = 30; // 0.3%

  before(async () => {
    [owner, treasury, user] = await ethers.getSigners();
  });

  beforeEach(async () => {
    // Deploy fresh contracts for each test using Hardhat's ethers.js
    const ExecutorMock = await ethers.getContractFactory("ExecutorMock");
    executor = await ExecutorMock.deploy();
    
    const GlueXRouter = await ethers.getContractFactory("GlueXRouterV2");
    router = await GlueXRouter.deploy(
      treasury.address, // Protocol treasury
      WETH // Native token (WETH)
    );
  });

  // Helper function to create swap parameters
  function createSwapParams(overrides = {}) {
    const deadline = Math.floor(Date.now()/1000) + 300; // 5 minutes
    return {
      inputToken: DAI,
      outputToken: WETH,
      inputAmount: TEST_AMOUNT,
      minOutput: MIN_OUTPUT,
      deadline: deadline,
      feeBps: FEE_BPS,
      permitData: [],
      ...overrides
    };
  }

  describe("Parameter Validation", () => {
    it("Should reject expired deadlines", async () => {
      const params = createSwapParams({
        deadline: Math.floor(Date.now()/1000) - 60 // Expired 1 minute ago
      });

      await expect(
        router.connect(user).executeSwap(executor.address, params, [])
      ).to.be.revertedWith("Deadline expired");
    });

    it("Should prevent same-token swaps", async () => {
      const params = createSwapParams({
        outputToken: DAI // Same as input
      });

      await expect(
        router.connect(user).executeSwap(executor.address, params, [])
      ).to.be.revertedWith("Same tokens");
    });
  });

  describe("Swap Execution", () => {
    it("Should complete ETH → ERC20 swap with fees", async () => {
      const ethAmount = parseEther("1");
      const params = createSwapParams({
        inputToken: WETH,
        inputAmount: ethAmount
      });

      const tx = await router.connect(user).executeSwap(
        executor.address,
        params,
        [],
        { value: ethAmount }
      );

      // Verify event emission
      await expect(tx)
        .to.emit(router, "SwapExecuted")
        .withArgs(
          user.address,
          WETH,
          WETH,
          ethAmount,
          MIN_OUTPUT,
          (MIN_OUTPUT * FEE_BPS) / 10000
        );
    });

    it("Should handle ERC20 → ERC20 swaps with Permit2", async () => {
      const permitData = "0x1234"; // Mock permit signature
      const params = createSwapParams({
        permitData: permitData
      });

      const tx = await router.connect(user).executeSwap(
        executor.address,
        params,
        []
      );

      // Verify fee distribution
      const feeAmount = (MIN_OUTPUT * FEE_BPS) / 10000;
      const finalOutput = MIN_OUTPUT - feeAmount;
      
      await expect(tx)
        .to.changeTokenBalance(params.outputToken, user, finalOutput)
        .to.changeTokenBalance(params.outputToken, treasury, feeAmount);
    });
  });

  describe("Edge Cases", () => {
    it("Should handle minimum viable output", async () => {
      const params = createSwapParams({
        inputAmount: parseEther("0.0001"), // 0.0001 DAI
        minOutput: parseEther("0.0000001") // 0.0000001 WETH
      });

      await expect(
        router.connect(user).executeSwap(executor.address, params, [])
      ).to.emit(router, "SwapExecuted");
    });

    it("Should reject swaps exceeding max fee", async () => {
      const params = createSwapParams({
        feeBps: 51 // Exceeds 0.5% max fee
      });

      await expect(
        router.connect(user).executeSwap(executor.address, params, [])
      ).to.be.revertedWith("Exceeds max fee");
    });
  });

  describe("Security Checks", () => {
    it("Should prevent reentrancy attacks", async () => {
      // Deploy malicious contract using Hardhat's ethers.js
      const MaliciousExecutor = await ethers.getContractFactory("MaliciousExecutor");
      const badExecutor = await MaliciousExecutor.deploy(router.address);
      
      const params = createSwapParams();

      await expect(
        router.connect(user).executeSwap(badExecutor.address, params, [])
      ).to.be.revertedWith("ReentrancyGuard: reentrant call");
    });

    it("Should only allow treasury to update fees", async () => {
      await expect(
        router.connect(user).updateFeeParameters(100)
      ).to.be.revertedWith("Unauthorized");
    });
  });
});