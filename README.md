## Project Description

1. Relative Stability Anchored/Pegged to USD$
   1. We will use Chainlink Price Feed to track price of DOllar
2. Stability mechanism will be Algorithmic (Processes of Minting and Burning will be controlled by Code)
   1. People can only mint the stablecoin with enought collateral
3. Collateral Type: Exogenous, and it will be Crypto --> WrappedBTC and WrappedETH

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
