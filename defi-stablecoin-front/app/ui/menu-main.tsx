"use client";
import React from "react";
import { usePathname } from "next/navigation";
import {
  Navbar,
  NavbarBrand,
  NavbarContent,
  NavbarItem,
  Button,
} from "@nextui-org/react";
import Link from "next/link.js";

import { Logo } from "./logo.jsx";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function MenuMain() {
  const pathname = usePathname();
  return (
    <Navbar shouldHideOnScroll isBordered className=' bg-transparent'>
      <NavbarBrand>
        <NavbarItem
          href='/'
          as={Link}
          className='text-white flex flex-row justify-center items-center gap-2'
        >
          <Logo />
          <p className='font-bold text-inherit'>USDD Protocol</p>
        </NavbarItem>
      </NavbarBrand>

      <NavbarContent justify='center'>
        <NavbarItem isActive={pathname === "liquidate"} className='text-white'>
          <Button
            size='lg'
            className='bg-gradient-to-tr from-indigo-500 to-orange-300 text-white shadow-lg hover:scale-105'
          >
            <Link color='secondary' href='/liquidate'>
              Liquidate
            </Link>
          </Button>
        </NavbarItem>

        <NavbarItem className='hidden md:flex'>
          <ConnectButton></ConnectButton>
        </NavbarItem>
      </NavbarContent>
    </Navbar>
  );
}
