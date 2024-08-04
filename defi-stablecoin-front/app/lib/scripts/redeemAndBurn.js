const ethers = require("ethers");
import { abiDSCEngine, abiWETH, abiUSDD } from "../../../constants/index";
require("dotenv").config();
const { config } = require("dotenv");

export default async function redeemAndBurn(
  tokenCollateral,
  amountOfCollateralToRedeem,
  amountToUssdToBurn
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

    const tx1 = await usdd.approve(
      addressContractDscEngine,
      amountToUssdToBurn
    );

    await tx1.wait();

    //!NOT WORKING await txApproval.wait(); saying is not a function
    // const receiptApproveUsdd = await txApproval.wait();

    // if (receiptApproveUsdd.status !== 1) {
    //   throw new Error("Approval transaction failed");
    // }

    console.log("Approval successful, proceeding with deposit...");

    const amountOfCollateralToRedeemInWei = ethers.utils.parseEther(
      amountOfCollateralToRedeem
    );

    const tx = await dscEngine.redeemCollateralAndGiveBackUSDD(
      tokenCollateral,
      amountOfCollateralToRedeemInWei,
      amountToUssdToBurn
    );
    await tx.wait();

    console.log(
      "Success to redeem collateral and return USDD__ScriptRedeemCollateralAndBurn"
    );
  } catch (error) {
    console.error(
      "Error redeeming Collateral and Burning__USDD__ScriptRedeemCollateralAndBurn: ",
      error
    );
  }
}
