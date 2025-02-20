import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ledger";
import "@nomicfoundation/hardhat-verify";
import "@typechain/hardhat";
import "module-alias/register";

import { EthGasReporterConfig } from "hardhat-gas-reporter/dist/src/types";
import "hardhat-gas-reporter";
import "hardhat-deploy";
import "hardhat-deploy-ethers";

import dotenv from "dotenv";

import "./tasks";

dotenv.config();

const REPORT_GAS = process.env["REPORT_GAS"]?.toLocaleLowerCase() === "true";

const gasReporter: EthGasReporterConfig = {
  enabled: REPORT_GAS,
  currency: "USD",
  outputFile: "gas-report.txt",
  noColors: true,
  token: "ETH",
};

if (process.env["COINMARKETCAP_API_KEY"]) {
  gasReporter.coinmarketcap = process.env["COINMARKETCAP_API_KEY"];
}
const ETHERSCAN_API_KEY = process.env["ETHERSCAN_API_KEY"] as string;
const ARBITRUM_API_KEY = process.env["ARBITRUM_API_KEY"] as string;

const ledgerAccounts = [
  "0x935967faD7ebE3E686cf3d835dEfEBA6B5a70CdC", // orivium admin public
];

const { PRIVATE_KEY } = process.env;
const testAccounts = PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [];

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
        details: {
          yul: true,
          yulDetails: {
            stackAllocation: true,
            optimizerSteps: "dhfoDgvulfnTUtnIf",
          },
        },
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
      initialDate: "2023-01-23T23:23:23.023+23:23",
    },
    localhost: {
      chainId: 31337,
    },
    sepolia: {
      url: "https://ethereum-sepolia.publicnode.com",
      chainId: 11155111,
      accounts: testAccounts,
    },
    goerli: {
      url: "https://ethereum-goerli.publicnode.com",
      chainId: 5,
      accounts: testAccounts,
    },
    arbitrumSepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      chainId: 421614,
      accounts: testAccounts,
    },
    xaiSepolia: {
      url: "https://testnet-v2.xai-chain.net/rpc",
      chainId: 37714555429,
      accounts: testAccounts,
    },
    xaiGoerli: {
      url: "https://testnet.xai-chain.net/rpc",
      chainId: 47279324479,
      accounts: testAccounts,
    },
    mainnet: {
      url: "https://ethereum.publicnode.com",
      chainId: 1,
      ledgerAccounts,
    },
    arbitrum: {
      url: "https://arbitrum-one.publicnode.com",
      chainId: 42161,
      ledgerAccounts,
    },
    xai: {
      url: "https://xai-chain.net/rpc",
      chainId: 660279,
      ledgerAccounts,
    },
  },
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY,
      arbitrumOne: ARBITRUM_API_KEY,

      goerli: ETHERSCAN_API_KEY,
      sepolia: ETHERSCAN_API_KEY,
      arbitrumGoerli: ETHERSCAN_API_KEY,
    },
  },
  gasReporter,
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./build/cache",
    artifacts: "./build/artifacts",
  },
  mocha: {
    timeout: 300000, // 300 seconds max for running tests
  },
  typechain: {
    outDir: "./typechain-types/src",
    target: "ethers-v6",
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    externalArtifacts: ["externalArtifacts/*.json"], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
    dontOverrideCompile: false, // defaults to false
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
};

export default config;
