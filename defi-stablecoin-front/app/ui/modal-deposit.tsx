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

import depositCollateral from "../lib/scripts/depositCollateral";

export default function ModalDeposit() {
  const [isOpen, setIsOpen] = useState(false);
  const [formData, setFormData] = useState({
    tokenAddress: "",
    amountToDeposit: "",
  });

  const handleChange = (e: any) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();

    console.log(formData.tokenAddress, formData.amountToDeposit);

    await depositCollateral(formData.tokenAddress, formData.amountToDeposit);

    // Close the modal after submission
    setIsOpen(false);
  };
  const handleCloseModal = () => {
    // Reset the form data when the modal is closed
    setFormData({
      tokenAddress: "",
      amountToDeposit: "",
    });
    setIsOpen(false);
  };

  return (
    <>
      <Button
        onPress={() => setIsOpen(true)}
        size='lg'
        className='bg-gradient-to-tr from-pink-500 to-yellow-500 text-white shadow-lg hover:scale-105'
      >
        Deposit Collateral
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
                label='Token Address'
                type='text'
                id='tokenAddress'
                name='tokenAddress'
                placeholder='Enter the address of Token Address'
                variant='bordered'
                value={formData.tokenAddress}
                onChange={handleChange}
                className=' text-indigo-600'
              />
              <Input
                label='amountToDeposit'
                placeholder='Enter the Amount To Deposit'
                type='text'
                id='amountToDeposit'
                name='amountToDeposit'
                value={formData.amountToDeposit}
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
                Deposit
              </Button>
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
