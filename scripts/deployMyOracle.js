const hre = require("hardhat");

async function main() {
  const myOracle = await hre.ethers.getContractFactory("myOracle");
  const MyOracle = await myOracle.deploy();

  await MyOracle.deployed();

  console.log(`myOracle deployed to ${MyOracle.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
