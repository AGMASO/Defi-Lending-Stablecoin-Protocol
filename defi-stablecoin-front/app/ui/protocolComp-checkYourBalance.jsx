import { useState, useEffect } from "react";
import checkBalanceCollateral from "../lib/scripts/checkBalanceCollateral";
import { ethers } from "ethers"; // Importing ethers

import {
  Table,
  TableHeader,
  TableBody,
  TableColumn,
  TableRow,
  TableCell,
} from "@nextui-org/table";

export default function ProtocolCheckBalance({ addressUser }) {
  const [wETH, setwETH] = useState();
  const [wBTC, setwBTC] = useState();
  const [balanceUSDD, setBalanceUsdd] = useState();
  const [usdValueCollateral, setUsdValueCollateral] = useState();

  // Utility function to format the address
  const formatAddress = `${addressUser.slice(0, 4)}...${addressUser.slice(-4)}`;

  useEffect(() => {
    async function checkBalanceCollateralEveryChange() {
      try {
        const { balanceWEth, balanceWBtc, balanceUSDD, usdValueCollateral } =
          await checkBalanceCollateral(addressUser);

        console.log("Esto es usdValue", usdValueCollateral);
        setwETH(ethers.utils.formatUnits(balanceWEth, "ether"));
        setwBTC(ethers.utils.formatUnits(balanceWBtc, "ether"));
        setBalanceUsdd(ethers.utils.formatUnits(balanceUSDD, "ether"));

        setUsdValueCollateral(
          ethers.utils.formatUnits(usdValueCollateral, "ether")
        );
      } catch (error) {
        console.error("Failed to fetch balances: ", error);
      }
    }

    if (addressUser) {
      checkBalanceCollateralEveryChange();
    }
  }, [addressUser]); // Dependency on addressUser to re-run when it changes
  return (
    <>
      <div className=' flex w-[90%]'>
        <Table aria-label='Collateral Tokens'>
          <TableHeader>
            <TableColumn className=' bg-lila text-white'>User</TableColumn>
            <TableColumn className=' bg-lila text-white'>WEth</TableColumn>
            <TableColumn className=' bg-lila text-white'>WBtc</TableColumn>
            <TableColumn className=' bg-lila text-white'>USDD</TableColumn>
            <TableColumn className=' bg-lila text-white'>
              Usd Value Collateral
            </TableColumn>
          </TableHeader>
          <TableBody>
            <TableRow key='1'>
              <TableCell>{formatAddress} </TableCell>
              <TableCell>{wETH || "Loading..."}</TableCell>
              <TableCell>{wBTC || "Loading..."}</TableCell>
              <TableCell>{balanceUSDD * 1e18 || "Loading..."}</TableCell>
              <TableCell>
                {usdValueCollateral
                  ? `$ ${parseFloat(usdValueCollateral).toFixed(2)}`
                  : "Loading..."}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </>
  );
}
