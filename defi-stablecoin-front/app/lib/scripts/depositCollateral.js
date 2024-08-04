const ethers = require("ethers");
import { abiDSCEngine, abiWETH } from "../../../constants/index";
require("dotenv").config();
const { config } = require("dotenv");

export default async function depositCollateral(tokenAddress, amountToDeposit) {
  console.log("estoy aqui");
  const wEth = "0xfff9976782d46cc05630d1f6ebab18b2324d6b14";

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

    const addressContractDscEngine =
      "0x0168f990Da7d23CF80d93f224bF21E0ABde81C11";

    const dscEngine = new ethers.Contract(
      addressContractDscEngine,
      abiDSCEngine,
      signer
    );

    if (tokenAddress == wEth) {
      console.log("TokenAddress equal to wETH");

      const tokenCollateral = new ethers.Contract(wEth, abiWETH, signer);

      const amountToDepositInWei = ethers.utils.parseEther(amountToDeposit);
      console.log("Amount To deposit in Wei", amountToDepositInWei.toString());

      const txApprove = await tokenCollateral.approve(
        addressContractDscEngine,
        amountToDepositInWei
      );
      const receiptApprove = await txApprove.wait();

      if (receiptApprove.status !== 1) {
        throw new Error("Approval transaction failed");
      }

      console.log("Approval successful, proceeding with deposit...");

      const tx = await dscEngine.depositCollateral(
        tokenAddress,
        amountToDepositInWei
      );
      await tx.wait();
      console.log(
        "Success to add Collateral to the Protocol__scriptDepositCollateral"
      );
    }
    // }else if ( tokenAddress == "0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC"){
    //   const tokenCollateral = new ethers.Contract(
    //     0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC,
    //     abiWBTC,
    //     signer
    //   );
    // }
  } catch (error) {
    console.error("Error adding Collateral to the Protocol: ", error);
  }
}
