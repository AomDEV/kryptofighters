import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-abi-exporter";
import "hardhat-docgen";
import { GetChain } from "./scripts/lib/environment";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  defaultNetwork: GetChain()?.hardhat ?? "localhost",
  networks: {
    bsc_mainnet: {
      url: process.env.BSC_MAINNET_URL || "",
      accounts: process.env.MAINNET_PRIVATE_KEY !== undefined ? process.env.MAINNET_PRIVATE_KEY.split(",") : [],
    },
    bsc_testnet: {
      url: process.env.BSC_TESTNET_URL || "",
      accounts: process.env.TESTNET_PRIVATE_KEY !== undefined ? process.env.TESTNET_PRIVATE_KEY.split(",") : [],
      gasMultiplier: 1.2
    },
    polygon_mainnet: {
      url: process.env.POLYGON_MAINNET_URL || "",
      accounts: process.env.MAINNET_PRIVATE_KEY !== undefined ? process.env.MAINNET_PRIVATE_KEY.split(",") : [],
    },
    polygon_testnet: {
      url: process.env.POLYGON_TESTNET_URL || "",
      accounts: process.env.TESTNET_PRIVATE_KEY !== undefined ? process.env.TESTNET_PRIVATE_KEY.split(",") : [],
      gasMultiplier: 1.2,
    },
    ethereum_mainnet: {
      url: process.env.ETHEREUM_MAINNET_URL || "",
      accounts: process.env.MAINNET_PRIVATE_KEY !== undefined ? process.env.MAINNET_PRIVATE_KEY.split(",") : [],
    },
    ethereum_testnet: {
      url: process.env.ETHEREUM_TESTNET_URL || "",
      accounts: process.env.TESTNET_PRIVATE_KEY !== undefined ? process.env.TESTNET_PRIVATE_KEY.split(",") : [],
      gasMultiplier: 2,
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: true,
  },
  abiExporter: {
    path: "./abi",
    clear: true,
    flat: true,
    spacing: 4,
  }
};

export default config;
