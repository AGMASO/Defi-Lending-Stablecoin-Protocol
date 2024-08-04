const ethers = require("ethers");
import { abiDSCEngine, abiWETH, abiUSDD } from "../../../constants/index";
require("dotenv").config();
const { config } = require("dotenv");

export default async function liquidate(
  collateralTokenAddress,
  user,
  debtToCover
) {
  console.log("estoy aqui");
  const wEth = "0xfff9976782d46cc05630d1f6ebab18b2324d6b14";
  const wBtc = "0x29f2D40B0605204364af54EC677bD022dA425d03";
  const addressContractDscEngine = "0x0168f990Da7d23CF80d93f224bF21E0ABde81C11";
  const USDDAddress = "0x7485aF5b1eE43CF349376f175aAA99be9Ed0d077";

  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    // Request access to the MetaMask account
    await window.ethereum.send("eth_requestAccounts");
    // Get the signer's address
    const signerAddress = (await provider.listAccounts())[0];
    console.log(signerAddress);

    // Create an instance of the signer using the provider and signer's address
    const signer = provider.getSigner(signerAddress);
    console.log(signer);

    console.log("estoy trabajando");

    const dscEngine = new ethers.Contract(
      addressContractDscEngine,
      abiDSCEngine,
      signer
    );
    const usdd = new ethers.Contract(USDDAddress, abiUSDD, signer);

    const tx1 = await usdd.approve(addressContractDscEngine, debtToCover);

    await tx1.wait();

    console.log("Approval successful, proceeding with Liquidation...");

    const tx = await dscEngine.liquidate(
      collateralTokenAddress,
      user,
      debtToCover
    );
    await tx.wait();

    console.log("Success to liquidate User __ScriptLiquidate");
  } catch (error) {
    console.error("Error to liquidate User __ScriptLiquidate", error);
  }
}
