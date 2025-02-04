const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GluexRouterPOC", function () {
  let router, treasury, owner, dummyToken, executor;

  beforeEach(async function () {
    [owner, treasury, addr1] = await ethers.getSigners();

    // Deploy DummyToken with modern ethers syntax
    const DummyToken = await ethers.getContractFactory("DummyToken");
    dummyToken = await DummyToken.deploy(
      "Dummy", 
      "DUM", 
      18, 
      ethers.parseEther("10000") // Fixed parseEther usage
    );

    // Deploy Executor
    const DummyExecutor = await ethers.getContractFactory("DummyExecutor");
    executor = await DummyExecutor.deploy();

    // Deploy GluexRouterPOC with ZeroAddress constant
    const Router = await ethers.getContractFactory("GluexRouterPOC");
    router = await Router.deploy(
      treasury.address, 
      ethers.ZeroAddress // Updated constant
    );

    // Transfer test tokens using modern syntax
    await dummyToken.transfer(
      await router.getAddress(), 
      ethers.parseEther("100")
    );
  });

  it("Should collect fees when called by treasury", async function () {
    // Initial check
    expect(await dummyToken.balanceOf(treasury.address)).to.equal(0);

    // Execute fee collection
    await router.connect(treasury).collectFees(
      [await dummyToken.getAddress()], 
      treasury.address
    );

    // Verify balance update
    expect(await dummyToken.balanceOf(treasury.address))
      .to.equal(ethers.parseEther("100"));
  });
});