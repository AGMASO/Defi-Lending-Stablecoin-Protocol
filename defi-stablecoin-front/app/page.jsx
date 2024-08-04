"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import Link from "next/link";
import Image from "next/image";
import MenuMain from "./ui/menu-main";
import { Button } from "@nextui-org/react";

import HeroComponent from "./ui/herocomponent";
import ModalDeposit from "./ui/modal-deposit";
import CodersComp from "./ui/coderscomp";
import MenuNotConnected from "./ui/menu-notConnected";

export default function Home() {
  const { address, isConnected, isDisconnected } = useAccount();
  return (
    <div className='min-h-screen'>
      {isDisconnected && <MenuNotConnected></MenuNotConnected>}
      {isConnected && <MenuMain></MenuMain>}
      <main className='flex-col justify-center'>
        <div className='flex justify-center mb-[70px] min-h-[60vh]'>
          {isConnected ? (
            <div className='flex flex-col w-[100%]'>
              <div className='flex justify-center items-center  mt-20'>
                <p className='line text-2xl text-white font-bold'>
                  To start the Protocol you need to deposit wETH or wBTC
                </p>
              </div>
              <div className='flex justify-center items-center  mt-20'>
                <p className='line text-2xl text-white font-bold'>
                  <ModalDeposit></ModalDeposit>
                </p>
              </div>
              <div className='flex justify-center items-center  mt-20'>
                <p className='line text-2xl text-white font-bold'>
                  Have you already done it?
                </p>
              </div>
              <div className='flex justify-center items-center  mt-20'>
                <p className='line text-2xl text-white font-bold'>
                  <Button
                    color='secondary'
                    size='lg'
                    href='/protocol'
                    as={Link}
                  >
                    Access Protocol
                  </Button>
                </p>
              </div>
            </div>
          ) : (
            <div className='flex flex-col'>
              <div className='w-[100%]'>
                <div className='w-[360px] sm:w-[1000px]'>
                  <HeroComponent></HeroComponent>
                </div>
              </div>

              <div className='w-[100%]'>
                {/* <div className='w-[360px] sm:w-[1000px]'>
                  <ExplanationComp></ExplanationComp>
                </div> */}
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
