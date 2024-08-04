"use client";

import { useAccount } from "wagmi";

import MenuMain from "../ui/menu-main";
import HeroComponent from "../ui/herocomponent";
import ModalDeposit from "../ui/modal-deposit";
import CodersComp from "../ui/coderscomp";
import MenuNotConnected from "../ui/menu-notConnected";
import ModalCheckIfUnderCollateralized from "../ui/liquidate-ModalCheckIfUndercolletarize";
import ModalLiquidate from "../ui/liquidate-ModalLiquidate";

export default function Protocol() {
  const { address, isConnected, isDisconnected } = useAccount();
  return (
    <div className='min-h-screen'>
      {isDisconnected && <MenuNotConnected></MenuNotConnected>}
      {isConnected && <MenuMain></MenuMain>}
      <main className='flex-col justify-center'>
        <div className='flex-col justify-center mb-[70px] min-h-[60vh]'>
          {isConnected ? (
            <>
              <div className='flex flex-col w-[100%]'>
                <div className='flex flex-col justify-center items-center  mt-20'>
                  <p className='line text-2xl text-white font-bold'>
                    Welcome to the Liquidate Section
                  </p>
                  <p className='line text-xl text-white font-bold w-[400px] pt-10'>
                    We give you the chance to liquidate Users who are
                    undercolletarize in the protocol. If you do so, you will get
                    rewards.
                  </p>
                </div>
              </div>
              <div className='flex flex-row w-[100%]'>
                <div className='flex flex-col justify-center items-center  w-[50%]'>
                  <p className=' text-white text-center mb-10 mt-10'>
                    Check if an User is undercolletarize
                  </p>
                  <ModalCheckIfUnderCollateralized></ModalCheckIfUnderCollateralized>
                </div>
                <div className='flex flex-col justify-center items-center  w-[50%]'>
                  <p className=' text-white text-center mb-10 mt-10'>
                    Click to Liquidate once you find an User undercolletarized
                  </p>
                  <ModalLiquidate></ModalLiquidate>
                </div>
              </div>
            </>
          ) : (
            <div className='flex flex-col w-[100%]'>
              <div className='flex justify-center items-center  mt-20'>
                <p className='line text-2xl text-white font-bold'>
                  Connect Your Wallet Please
                </p>
              </div>
            </div>
          )}
        </div>
        <div className='w-[100%] h-36 bottom-0'>
          <div className='sm:w-[100%] h-full'>
            <CodersComp></CodersComp>
          </div>
        </div>
      </main>
    </div>
  );
}
