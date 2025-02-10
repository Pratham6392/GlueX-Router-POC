const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DummyExecutor", function () {
  let dummyExecutor, testTarget;
  let owner;

  // Deploy the contracts before each test
  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    // Deploy DummyExecutor
    const DummyExecutorFactory = await ethers.getContractFactory("DummyExecutor");
    dummyExecutor = await DummyExecutorFactory.deploy();
    await dummyExecutor.deployed();

    // Deploy TestTarget – a simple contract that increments a counter
    const TestTargetFactory = await ethers.getContractFactory("TestTarget");
    testTarget = await TestTargetFactory.deploy();
    await testTarget.deployed();
  });

  it("should execute an interaction that calls increment on TestTarget", async function () {
    // Prepare the function call data for TestTarget.increment(uint256)
    const iface = new ethers.utils.Interface([
      "function increment(uint256 value) external payable"
    ]);
    // Encode a call to increment(5)
    const callData = iface.encodeFunctionData("increment", [5]);

    // Prepare the Interaction object:
    // Interaction is defined as:
    // struct Interaction {
    //   address target;
    //   uint256 value;
    //   bytes callData;
    // }
    // We create an array with one interaction.
    const interactions = [{
      target: testTarget.address,
      value: 0, // no ETH sent
      callData: callData
    }];

    // Execute the route:
    // The second parameter (outputToken) is unused in DummyExecutor.
    // We'll pass testTarget.address as a dummy IERC20 address.
    await dummyExecutor.executeRoute(interactions, testTarget.address);

    // Verify that the counter was incremented by 5.
    expect(await testTarget.counter()).to.equal(5);
  });

  it("should revert with proper message if interaction fails", async function () {
    // Prepare an invalid call (e.g., wrong function selector)
    const invalidCallData = "0x12345678"; // Not a valid function in TestTarget
    const interactions = [{
      target: testTarget.address,
      value: 0,
      callData: invalidCallData
    }];

    // Expect the call to revert.
    await expect(
      dummyExecutor.executeRoute(interactions, testTarget.address)
    ).to.be.revertedWith("Transaction reverted silently");
  });
});
