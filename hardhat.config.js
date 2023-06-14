require("@nomicfoundation/hardhat-toolbox");
require("hardhat-docgen");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      forking: process.env.FANTOM_RPC,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  docgen: {
    path: "./docs",
    clear: true,
    runOnCompile: true,
  },
};
