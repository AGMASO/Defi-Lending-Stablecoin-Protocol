import { useState, useEffect } from "react";
import { ethers } from "ethers"; // Importing ethers
import {
  Modal,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Button,
  Input,
} from "@nextui-org/react";

import ModalMint from "./protocol-ModalMintUSDD";
import ModalRedeemAndBurn from "./protocol-ModalRedeemAndBurn";
import ModalRedeem from "./protocol-ModalRedeem";

export default function ProtocolActions({ addressUser }) {
  return (
    <>
      <div className='flex flex-col w-[100%]'>
        <div className=' flex flex-col justify-center items-center gap-3'>
          <div>
            <ModalMint></ModalMint>
          </div>
          <div>
            <ModalRedeem></ModalRedeem>
          </div>
          <div>
            <ModalRedeemAndBurn></ModalRedeemAndBurn>
          </div>
        </div>
      </div>
    </>
  );
}
