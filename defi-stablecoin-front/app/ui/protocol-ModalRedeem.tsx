import {
  Modal,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Button,
  Input,
} from "@nextui-org/react";
import { useState } from "react";

import redeemCollateral from "../lib/scripts/redeemCollateral";

export default function ModalRedeem() {
  const [isOpen, setIsOpen] = useState(false);
  const [formData, setFormData] = useState({
    tokenCollateral: "",
    amountToRedeem: "",
  });

  const handleChange = (e: any) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();

    console.log(formData.tokenCollateral, formData.amountToRedeem);

    await redeemCollateral(formData.tokenCollateral, formData.amountToRedeem);

    // Close the modal after submission

    window.location.href = "/protocol";
  };
  const handleCloseModal = () => {
    // Reset the form data when the modal is closed
    setFormData({
      tokenCollateral: "",
      amountToRedeem: "",
    });
    setIsOpen(false);
  };

  return (
    <>
      <Button
        onPress={() => setIsOpen(true)}
        size='lg'
        className='bg-gradient-to-tr from-indigo-500 to-orange-300 text-white shadow-lg hover:scale-105'
      >
        Redeem Collateral
      </Button>
      <Modal isOpen={isOpen} onClose={handleCloseModal} placement='top-center'>
        <ModalContent>
          <form onSubmit={handleSubmit}>
            <ModalHeader className='flex flex-col gap-1'>
              Deposit Collateral
            </ModalHeader>
            <ModalBody>
              <Input
                autoFocus
                label='Token Collateral'
                type='text'
                id='tokenCollateral'
                name='tokenCollateral'
                placeholder='Enter the address of Token Collateral to Redeem'
                variant='bordered'
                value={formData.tokenCollateral}
                onChange={handleChange}
                className=' text-indigo-600'
              />
              <Input
                label='Amount to Redeem'
                placeholder='Enter the Amount To Redeem'
                type='text'
                id='amountToRedeem'
                name='amountToRedeem'
                value={formData.amountToRedeem}
                onChange={handleChange}
                variant='bordered'
                className=' text-indigo-600'
              />
            </ModalBody>
            <ModalFooter>
              <Button color='danger' variant='flat' onClick={handleCloseModal}>
                Close
              </Button>
              <Button type='submit' color='primary'>
                Redeem Collateral
              </Button>
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
