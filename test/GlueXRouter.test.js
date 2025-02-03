// test/GlueXRouter.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GlueXRouterV2", () => {
  let router, factory, tokenA, tokenB, weth;

  before(async () => {
    [owner] = await ethers.getSigners();

    // Deploy mock contracts
    const ERC20 = await ethers.getContractFactory("ERC20Mock");
    tokenA = await ERC20.deploy("TokenA", "TKNA");
    tokenB = await ERC20.deploy("TokenB", "TKNB");
    weth = await ERC20.deploy("WETH", "WETH");

    const Factory = await ethers.getContractFactory("UniswapV2FactoryMock");
    factory = await Factory.deploy();

    // Deploy router
    const Router = await ethers.getContractFactory("GlueXRouterV2");
    router = await Router.deploy(factory.address, weth.address);

    // Setup liquidity
    await factory.createPair(tokenA.address, tokenB.address);
    await tokenA.mint(owner.address, ethers.utils.parseEther("1000"));
    await tokenB.mint(owner.address, ethers.utils.parseEther("1000"));
    await tokenA.approve(router.address, ethers.constants.MaxUint256);
    await tokenB.approve(router.address, ethers.constants.MaxUint256);
  });

  it("should perform ETH to token swap", async () => {
    const params = {
      amountIn: ethers.utils.parseEther("1"),
      amountOutMin: 0,
      path: [weth.address, tokenB.address],
      recipient: owner.address,
      deadline: Math.floor(Date.now() / 1000) + 300,
      permit: "0x"
    };

    await router.swapExactETHForTokens(params, { value: params.amountIn });
    const balance = await tokenB.balanceOf(owner.address);
    expect(balance).to.be.gt(0);
  });

  it("should perform token to token swap", async () => {
    const params = {
      amountIn: ethers.utils.parseEther("1"),
      amountOutMin: 0,
      path: [tokenA.address, tokenB.address],
      recipient: owner.address,
      deadline: Math.floor(Date.now() / 1000) + 300,
      permit: "0x"
    };

    await router.swapExactTokensForTokens(params);
    const balance = await tokenB.balanceOf(owner.address);
    expect(balance).to.be.gt(0);
  });
});