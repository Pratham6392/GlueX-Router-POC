const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GluexRouterPOC", function () {
    let dummyToken, router, executor;
    let owner, treasury, user, other;
    const feeBpsValue = 30; // 30 bps = 0.3%

    beforeEach(async function () {
        [owner, treasury, user, other] = await ethers.getSigners();

        // Deploy DummyToken (mintable ERC20)
        const DummyTokenFactory = await ethers.getContractFactory("DummyToken");
        dummyToken = await DummyTokenFactory.deploy("Dummy Token", "DUM");
        await dummyToken.deployed();

        // Deploy DummyExecutor
        const DummyExecutorFactory = await ethers.getContractFactory("DummyExecutor");
        executor = await DummyExecutorFactory.deploy();
        await executor.deployed();

        // Deploy GluexRouterPOC with treasury and nativeToken addresses.
        // For testing, we use dummyToken as the native token.
        const GluexRouterFactory = await ethers.getContractFactory("GluexRouterPOC");
        router = await GluexRouterFactory.deploy(treasury.address, dummyToken.address);
        await router.deployed();

        // Set fee using treasury
        await router.connect(treasury).setFee(feeBpsValue);
    });

    it("should execute route and distribute output correctly", async function () {
        // Simulate user depositing input tokens
        const inputAmount = ethers.utils.parseEther("100");
        await dummyToken.mint(user.address, inputAmount);
        await dummyToken.connect(user).approve(router.address, inputAmount);

        // Prepare an interaction that mints output tokens to the router.
        // This simulates a successful route execution that increases the router's output token balance.
        const mintAmount = ethers.utils.parseEther("120"); // Simulate a gain (20% bonus)
        const iface = new ethers.utils.Interface(["function mint(address to, uint256 amount)"]);
        const callData = iface.encodeFunctionData("mint", [router.address, mintAmount]);
        const interactions = [{
            target: dummyToken.address,
            value: 0,
            callData: callData
        }];

        // Construct route parameters.
        const latestBlock = await ethers.provider.getBlock("latest");
        const routeParams = {
            inputToken: dummyToken.address,
            outputToken: dummyToken.address,
            inputAmount: inputAmount,
            minOutputAmount: ethers.utils.parseEther("110"), // Require at least 110 output tokens
            deadline: latestBlock.timestamp + 1000,
            routeId: ethers.constants.HashZero,
            permitData: "0x"
        };

        // Record initial balances.
        const userBalanceBefore = await dummyToken.balanceOf(user.address);
        const treasuryBalanceBefore = await dummyToken.balanceOf(treasury.address);

        // Execute the route.
        await router.connect(user).executeRoute(executor.address, routeParams, interactions);

        // Expected output: minted amount of 120 tokens.
        // Fee = (120 * feeBps) / 10,000 = (120 * 30) / 10000 = 0.36 tokens (approx)
        // Final amount = 120 - 0.36 = 119.64 tokens.
        // User originally had inputAmount, which is deducted, then receives final amount.
        const userBalanceAfter = await dummyToken.balanceOf(user.address);
        const treasuryBalanceAfter = await dummyToken.balanceOf(treasury.address);

        const expectedUserBalance = userBalanceBefore.sub(inputAmount).add(ethers.utils.parseEther("119.64"));
        expect(userBalanceAfter).to.be.closeTo(expectedUserBalance, ethers.utils.parseEther("0.001"));
        expect(treasuryBalanceAfter.sub(treasuryBalanceBefore)).to.be.closeTo(ethers.utils.parseEther("0.36"), ethers.utils.parseEther("0.001"));
    });
});
