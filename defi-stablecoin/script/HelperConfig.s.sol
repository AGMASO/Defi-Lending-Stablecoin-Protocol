// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.t.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE_ETH = 2900e8;
    int256 public constant INITIAL_PRICE_BTC = 60000e8;
    uint256 public DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    struct NetworkConfig {
        address priceFeedEth;
        address priceFeedBtc;
        address wEth;
        address wBtc;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            priceFeedEth: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            priceFeedBtc: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wEth: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14, //0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9
            wBtc: 0x29f2D40B0605204364af54EC677bD022dA425d03,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return sepoliaNetworkConfig;
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory)
    {
        //Check if activeNetwaor already has something

        if (activeNetworkConfig.priceFeedEth != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3AggregatorEth = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE_ETH
        );
        ERC20Mock wEthMock = new ERC20Mock("WETH", "WETH", msg.sender, 1000e8);
        MockV3Aggregator mockV3AggregatorBtc = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE_BTC
        );
        ERC20Mock wBTCMock = new ERC20Mock("WBTC", "WBTC", msg.sender, 1000e8);

        vm.stopBroadcast();

        NetworkConfig memory anvilLocalNetworkConfig = NetworkConfig({
            priceFeedEth: address(mockV3AggregatorEth),
            priceFeedBtc: address(mockV3AggregatorBtc),
            wEth: address(wEthMock),
            wBtc: address(wBTCMock),
            deployerKey: DEFAULT_ANVIL_KEY
        });

        return anvilLocalNetworkConfig;
    }
}
