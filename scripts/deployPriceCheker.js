const hre = require("hardhat");

async function main() {
  const priceChecker = await hre.ethers.getContractFactory("PriceChecker");
  const PriceChecker = await priceChecker.deploy();

  await PriceChecker.deployed();

  console.log(`PriceChecker deployed to ${PriceChecker.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
