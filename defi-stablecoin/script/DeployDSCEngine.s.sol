// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DecentralizedStablecoin} from "../src/DecentralizedStablecoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSCEngine is Script {
    function run()
        external
        returns (DSCEngine, HelperConfig, DecentralizedStablecoin)
    {
        HelperConfig helperConfig = new HelperConfig();
        (
            address priceFeedEth,
            address priceFeedBtc,
            address wEth,
            address wBtc,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        address deployerKeyAddress = vm.addr(deployerKey);
        vm.startBroadcast(deployerKey);
        DecentralizedStablecoin usdd = new DecentralizedStablecoin(
            deployerKeyAddress
        );
        DSCEngine dsc = new DSCEngine(
            priceFeedEth,
            priceFeedBtc,
            wEth,
            wBtc,
            address(usdd)
        );
        usdd.transferOwnership(address(dsc));
        vm.stopBroadcast();

        //!Ejecutamos el transferOwnerShip fuer del vm.startBroadcast porque si no el msg.sender es el deployerKey,
        //! y en este caso necesitamos que sea DeployDSCEngine, ya que es el owner del DecentralizedStablecoin debido
        //! a que hemos escrito address(this);
        //No estaba cambiando el owner de esta forma, asi que le hardcoded la wallet addres por ahora,
        // y le cambio el ownership dentro del vm.broadcast();

        return (dsc, helperConfig, usdd);
    }
}
