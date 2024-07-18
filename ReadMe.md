# Blockchain Research Projects

Welcome to the Blockchain Research Projects repository! This repository contains my research and coding experiments on various blockchain topics including Automated Market Makers (AMM), Gas Puzzles, NFTs, Single Collateral DAI, and Token Standards.

## Table of Contents

- [Blockchain Research Projects](#blockchain-research-projects)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Setup and Installation](#setup-and-installation)
  - [Research Topics](#research-topics)
    - [Automated Market Makers (AMM)](#automated-market-makers-amm)
    - [Gas Puzzles](#gas-puzzles)
    - [Non-Fungible Tokens (NFTs)](#non-fungible-tokens-nfts)
    - [Single Collateral DAI](#single-collateral-dai)
    - [Token Standards](#token-standards)
  - [Learning Resources](#learning-resources)
  - [Contributing](#contributing)
  - [License](#license)

## Introduction

This repository showcases my research on various blockchain topics. Each project contains code implementations, detailed explanations, and insights gained from my studies. The goal is to deepen the understanding of these topics and contribute to the broader blockchain development community.

## Setup and Installation

To get started with this repository, follow these steps:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/smbsp/research-blockchain.git
    cd research-blockchain
    ```

2. **Install dependencies**:
    Ensure you have [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) installed, then run:
    ```sh
    npm install
    ```

3. **Compile the contracts**:
    Use Hardhat to compile the smart contracts:
    ```sh
    npx hardhat compile
    ```

4. **Run tests**:
    Execute the tests to verify the implementations:
    ```sh
    npx hardhat test
    ```

## Research Topics

### Automated Market Makers (AMM)

Automated Market Makers are smart contracts that facilitate the trading of digital assets without requiring a traditional order book. They use mathematical formulas to price assets.

- **Implementation File**: [AMM.sol](./contracts/AMM.sol)
- **Test File**: [AMM.test.js](./test/AMM.test.js)

### Gas Puzzles

Gas puzzles are challenges designed to optimize gas usage in Ethereum smart contracts. They help developers understand and minimize gas consumption, which is crucial for efficient contract execution.

- **Gas Puzzle Implementations**: [GasPuzzle.sol](./contracts/GasPuzzle.sol)
- **Test File**: [GasPuzzle.test.js](./test/GasPuzzle.test.js)

### Non-Fungible Tokens (NFTs)

NFTs are unique digital assets representing ownership of specific items or content, verified through blockchain technology.

- **NFT Implementation**: [NFT.sol](./contracts/NFT.sol)
- **Test File**: [NFT.test.js](./test/NFT.test.js)

### Single Collateral DAI

Single Collateral DAI (SCD) is an early version of the DAI stablecoin system that uses a single collateral type (ETH) to back its value. This system has been replaced by Multi-Collateral DAI (MCD).

- **Single Collateral DAI Implementation**: [SingleCollateralDAI.sol](./contracts/SingleCollateralDAI.sol)
- **Test File**: [SingleCollateralDAI.test.js](./test/SingleCollateralDAI.test.js)

### Token Standards

Token standards define the rules and interfaces for tokens on the Ethereum blockchain. Common standards include ERC-20, ERC-721, and ERC-1155.

- **ERC-20 Implementation**: [ERC20.sol](./contracts/ERC20.sol)
- **ERC-721 Implementation**: [ERC721.sol](./contracts/ERC721.sol)
- **ERC-1155 Implementation**: [ERC1155.sol](./contracts/ERC1155.sol)
- **Test Files**: Corresponding test files for each token standard are available in the [test](./test) directory.

## Learning Resources

- [Automated Market Makers](https://uniswap.org/docs/v2/protocol-overview/how-uniswap-works/)
- [Ethereum Gas](https://ethereum.org/en/developers/docs/gas/)
- [Understanding NFTs](https://ethereum.org/en/nft/)
- [MakerDAO Single Collateral DAI](https://makerdao.com/en/whitepaper/)
- [ERC Standards](https://ethereum.org/en/developers/docs/standards/tokens/)

## Contributing

Contributions are welcome! If you have improvements or additional implementations to add, please submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
