## Project Description

# Overview

The DSCENGINE project is a decentralized stablecoin system designed to maintain a 1:1 peg with the USD. It operates similarly to DAI but without a DAO, no fees, and is exclusively backed by wBTC and wETH. This system is designed to always be overcollateralized, ensuring the value of the collateral is always greater than the issued stablecoin.

# Key Features

1. Relative Stability Anchored/Pegged to USD$
   1. We will use Chainlink Price Feed to track price of DOllar
2. Stability mechanism will be Algorithmic (Processes of Minting and Burning will be controlled by Code)
   1. People can only mint the stablecoin with enought collateral
3. Collateral Type: Exogenous, and it will be Crypto --> WrappedBTC and WrappedETH

## Smart Contracts
# DSCEngine Contract

This contract handles the core functionalities of the DSC system, including minting, redeeming, and liquidating stablecoins.

# Key Functions
**depositCollateralAndMintUSDD**: Allows users to deposit collateral and mint USDD in one transaction.
**redeemCollateral**: Allows users to redeem their collateral, provided the health factor remains above 1.
**redeemCollateralAndGiveBackUSDD**: Allows users to burn USDD and redeem their collateral in one transaction.
**mintUSDD**: Mints new USDD tokens.
**burnUSDD**: Burns USDD tokens to balance the collateral.
**liquidate**: Allows users to liquidate undercollateralized positions, incentivizing the maintenance of overcollateralization.


# DecentralizedStablecoin Contract

This contract implements the ERC20 token standard and includes additional functionality for minting and burning tokens.

# Key Functions
**burn**: Allows the owner to burn tokens, reducing the total supply.
**mint**: Allows the owner to mint new tokens, increasing the total supply.

## Project Backend SetUp

You will need to create a .env file with the next variables if you wish to deploy to
Sepolia Testnet:

RPC_URL_SEPOLIA=
ETHERSCAN_API=
PRIVATE_KEY=

## Deploy Contracts to Sepolia

Use in the console: make deploy ARGS="--network sepolia"

## Project Frontend Setup

## Getting Started

1. npm install to install all the packages of the package.json

2. Add a .env with your data:

   ALCHEMY_ID =
   PRIVATE_KEY =

3. run the development server:

```bash
npm run dev

```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.
