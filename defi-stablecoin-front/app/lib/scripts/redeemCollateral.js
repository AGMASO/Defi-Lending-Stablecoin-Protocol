const ethers = require("ethers");
import { abiDSCEngine, abiWETH, abiUSDD } from "../../../constants/index";
require("dotenv").config();
const { config } = require("dotenv");

export default async function redeemCollateral(
  tokenCollateral,
  amountToRedeem
) {
  console.log("estoy aqui");
  const wEth = "0xfff9976782d46cc05630d1f6ebab18b2324d6b14";
  const wBtc = "0x29f2D40B0605204364af54EC677bD022dA425d03";
  const addressContractDscEngine = "0x0168f990Da7d23CF80d93f224bF21E0ABde81C11";

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
    const amountToRedeemInWei = ethers.utils.parseEther(amountToRedeem);
    const tx = await dscEngine.redeemCollateral(
      tokenCollateral,
      amountToRedeemInWei
    );
    const receiptApprove = await tx.wait();

    if (receiptApprove.status !== 1) {
      throw new Error("Approval transaction failed");
    }

    console.log("Success to redeem collateral__ScriptRedeemCollateral");
  } catch (error) {
    console.error(
      "Error to redeem collateral__ScriptRedeemCollateral: ",
      error
    );
  }
}
