async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const Router = await ethers.getContractFactory("GluexRouterPOC");
    // Replace with your treasury address and native token address (or address(0) if using native ETH)
    const router = await Router.deploy("0xYourTreasuryAddress", "0xYourNativeTokenAddress");
    await router.deployed();
  
    console.log("GluexRouterPOC deployed to:", router.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  