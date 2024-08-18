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

import checkHealthFactor from "../lib/scripts/checkHealthFactor";

export default function ModalCheckIfUnderCollateralized() {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    addressUser: "",
  });
  const [isUnderCollaterize, setIsUnderCollaterize] = useState(false);

  const handleChange = (e: any) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    setIsLoading(true);
    console.log(formData.addressUser);

    const checkHealthFactorValue = await checkHealthFactor(
      formData.addressUser
    );
    if (checkHealthFactorValue < 1000000000000000000) {
      setIsUnderCollaterize(true);
    } else {
      setIsUnderCollaterize(false);
    }
  };

  const handleCloseModal = () => {
    // Reset the form data when the modal is closed
    setFormData({
      addressUser: "",
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
        Check Health Factor
      </Button>
      <Modal isOpen={isOpen} onClose={handleCloseModal} placement='top-center'>
        <ModalContent>
          <form onSubmit={handleSubmit}>
            <ModalHeader className='flex flex-col gap-1'>
              Check Health Factor
              {isUnderCollaterize && !isLoading ? (
                <p className=' text-red-500 text-sm'>
                  Selected User is Undercollaterized, You can Liquidate!
                </p>
              ) : (
                ""
              )}
              {!isUnderCollaterize && isLoading ? (
                <p className=' text-green-400 , text-sm'>
                  Not Undercollaterized
                </p>
              ) : (
                ""
              )}
            </ModalHeader>
            <ModalBody>
              <Input
                autoFocus
                label='User To Check'
                type='text'
                id='addressUser'
                name='addressUser'
                placeholder='Enter the address of the user to check'
                variant='bordered'
                value={formData.addressUser}
                onChange={handleChange}
                className=' text-indigo-600'
              />
            </ModalBody>
            <ModalFooter>
              <Button color='danger' variant='flat' onClick={handleCloseModal}>
                Close
              </Button>

              <Button type='submit' color='primary'>
                Check
              </Button>
            </ModalFooter>
          </form>
        </ModalContent>
      </Modal>
    </>
  );
}
