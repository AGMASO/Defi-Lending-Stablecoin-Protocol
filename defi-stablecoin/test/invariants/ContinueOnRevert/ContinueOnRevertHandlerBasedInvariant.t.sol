// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console} from "forge-std/Script.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {MockV3Aggregator} from "../../mocks/MockV3Aggregator.t.sol";

import {DeployDSCEngine} from "../../../script/DeployDSCEngine.s.sol";
import {DSCEngine} from "../../../src/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../../src/DecentralizedStablecoin.sol";
import {HelperConfig} from "../../../script/HelperConfig.s.sol";
import {ContinueOnRevertHandler} from "./ContinueOnRevertHandler.t.sol";

/// @title Stateful Test Invariant Handler-based for DSCEngine.sol contract
/// @author Agm
/// @notice Testing with Handler, the way to introduce boundaries to our Fuzzing test to make it works well in all the cases we need
/// @dev We need to define in the setUp() the targetContract.
//!  INVARIANTS: 1- Amount of COllateral value in Usd must be allways greater than USDD amount minted.
//!             2- All the getfunctions will never revert.
contract ContinueOnRevertHandlerBasedInvariant is StdInvariant, Test {
    DSCEngine public s_dscEngine;
    DecentralizedStablecoin public s_usdd;
    HelperConfig public s_helper;
    ContinueOnRevertHandler public s_handler;

    address public USER = makeAddr("user");
    address public LIQUIDATOR = makeAddr("liquidator");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant FEED_PRECISION = 1e8;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // This means you need to be 200% over-collateralized
    uint256 private constant PRECISION = 1e18;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATION_BONUS = 10;
    address public wETH;
    address public wBTC;
    MockV3Aggregator public s_priceFeedETH;
    MockV3Aggregator public s_priceFeedBTC;

    function setUp() public {
        DeployDSCEngine deployer = new DeployDSCEngine();
        (s_dscEngine, s_helper, s_usdd) = deployer.run();
        vm.deal(USER, STARTING_VALUE);
        wETH = s_dscEngine.getSwETH();
        wBTC = s_dscEngine.getSwBTC();
        s_priceFeedBTC = MockV3Aggregator(s_dscEngine.getSpriceFeedBTC());
        s_priceFeedETH = MockV3Aggregator(s_dscEngine.getSpriceFeedETH());
        s_handler = new ContinueOnRevertHandler(s_dscEngine, s_usdd);
        targetContract(address(s_handler));
    }

    /// forge-config: default.invariant.runs = 128
    /// forge-config: default.invariant.depth = 128
    /// forge-config: default.invariant.fail-on-revert = false
    function invariant_protocolMustHaveMoreValueThanSupplyFalse() public view {
        uint256 amountOfUsddMinted = s_usdd.totalSupply();
        console.log("TotalSupply of USDD", amountOfUsddMinted);

        uint256 totalWethDeposited = IERC20(wETH).balanceOf(
            address(s_dscEngine)
        );

        uint256 totalBTCDeposited = IERC20(wBTC).balanceOf(
            address(s_dscEngine)
        );

        uint256 wEthValue = s_dscEngine.getUsdValueETH(totalWethDeposited);
        console.log("Total WETH deposited as Collateral in USD: ", wEthValue);
        uint256 wBtcValue = s_dscEngine.getUsdValueBTC(totalBTCDeposited);
        console.log("Total WBTC deposited as Collateral in USD: ", wBtcValue);
        console.log("Times Mint Called: ", s_handler.timesMintCalled());

        assert(wEthValue + wBtcValue >= amountOfUsddMinted);
    }
}
