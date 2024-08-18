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

import liquidate from "../lib/scripts/liquidate";

export default function ModalLiquidate() {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    collateralTokenAddress: "",
    user: "",
    debtToCover: "",
  });

  const handleChange = (e: any) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    setIsLoading(true);
    console.log(formData.collateralTokenAddress);
    console.log(formData.user);
    console.log(formData.debtToCover);

    await liquidate(
      formData.collateralTokenAddress,
      formData.user,
      formData.debtToCover
    );
    setIsLoading(false);
    // reboost page after finishing

    //window.location.href = "/liquidate";
  };
  const handleCloseModal = () => {
    // Reset the form data when the modal is closed
    setFormData({
      collateralTokenAddress: "",
      user: "",
      debtToCover: "",
    });
    setIsOpen(false);
    setIsLoading(false);
  };

  return (
    <>
      <Button
        onPress={() => setIsOpen(true)}
        size='lg'
        className='bg-gradient-to-tr from-indigo-500 to-orange-300 text-white shadow-lg hover:scale-105'
      >
        Liquidate
      </Button>
      <Modal isOpen={isOpen} onClose={handleCloseModal} placement='top-center'>
        <ModalContent>
          <form onSubmit={handleSubmit}>
            <ModalHeader className='flex flex-col gap-1'>Liquidate</ModalHeader>
            <ModalBody>
              <Input
                autoFocus
                label='Token Collateral'
                type='text'
                id='collateralTokenAddress'
                name='collateralTokenAddress'
                placeholder='Enter the address of Collateral Token'
                variant='bordered'
                value={formData.collateralTokenAddress}
                onChange={handleChange}
                className=' text-indigo-600'
              />
              <Input
                autoFocus
                label='User To Liquidate'
                type='text'
                id='user'
                name='user'
                placeholder='Enter the address of the user to liquidate'
                variant='bordered'
                value={formData.user}
                onChange={handleChange}
                className=' text-indigo-600'
              />
              <Input
                autoFocus
                label='Debt To Cover'
                type='text'
                id='debtToCover'
                name='debtToCover'
                placeholder='Amount of Debt to Cover'
                variant='bordered'
                value={formData.debtToCover}
                onChange={handleChange}
                className=' text-indigo-600'
              />
            </ModalBody>
            <ModalFooter>
              <Button color='danger' variant='flat' onClick={handleCloseModal}>
                Close
              </Button>
              {!isLoading ? (
                <Button type='submit' color='primary'>
                  Liquidate
                </Button>
              ) : (
                <Button color='primary' isLoading>
                  Liquidate
                </Button>
              )}
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
