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

import mintUSDD from "../lib/scripts/mintUSDD";

export default function ModalMint() {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    amountUSDDToMint: "",
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

    console.log(formData.amountUSDDToMint);

    await mintUSDD(formData.amountUSDDToMint);

    // Close the modal after submission
    //setIsOpen(false);
    setIsLoading(false);
    window.location.href = "/protocol";
  };
  const handleCloseModal = () => {
    // Reset the form data when the modal is closed
    setFormData({
      amountUSDDToMint: "",
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
        Take Loan / Mint USDD
      </Button>
      <Modal isOpen={isOpen} onClose={handleCloseModal} placement='top-center'>
        <ModalContent>
          <form onSubmit={handleSubmit}>
            <ModalHeader className='flex flex-col gap-1'>
              Take Loan / Mint USDD
            </ModalHeader>
            <ModalBody>
              <Input
                autoFocus
                label='Mint Usdd'
                type='text'
                id='mintUsdd'
                name='amountUSDDToMint'
                placeholder='How much USDD to mint'
                variant='bordered'
                value={formData.amountUSDDToMint}
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
                  Mint USDD
                </Button>
              ) : (
                <Button color='primary' isLoading>
                  Mint USDD
                </Button>
              )}
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
