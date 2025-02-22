# Orivium King V2

## Overview

This project contains the smart contracts for the Orivium King V2. It implements a dynamic NFT ecosystem where each token ("King") has fully on-chain generated metadata. The contracts also support functionalities such as equipping items, staking, and cross-chain bridging using LayerZero.

## Features

- **Dynamic NFT Metadata**: Real-time, on-chain updates of token metadata based on equipped items.
- **Staking**: Stake NFTs to earn $ORI token
- **Cross-Chain Bridging**: Seamless transfer of tokens between chains using LayerZero.
- **Modular Architecture**: Composed of several interlinked contracts handling ERC721 tokens, item management, and bridging.

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v20 or later)
- [Yarn](https://yarnpkg.com/) (v4.1.0 as specified)
- [Hardhat](https://hardhat.org/)
- [Foundry](https://book.getfoundry.sh/)

## Usage 💡

### Compile Contracts 🛠️

To compile the smart contracts, run:
```sh
forge build
```

### Run Tests ✅

To run the tests, use:
```sh
forge test
```

### Start Local Node 🌐

To start a local Hardhat node, run:
```sh
yarn start:local
```

### Generate Typechain Types 📜

To generate Typechain types, use:
```sh
yarn typechain
```

## Tasks 🔧

Before using tasks, make sure to generate Typechain types:
```sh
yarn typechain
```

To get the available tasks run

```sh
npx hardhat --help
```