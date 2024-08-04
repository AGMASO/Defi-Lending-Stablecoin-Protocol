// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../src/DecentralizedStablecoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DSCEngine public s_dscEngine;
    address public USER = makeAddr("user");
    address public s_priceFeedEth;
    address public s_priceFeedBtc;
    address public s_wEth;
    address public s_wBtc;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;

    function setUp() public {
        vm.deal(USER, STARTING_VALUE);

        HelperConfig helperConfig = new HelperConfig();
        (
            address priceFeedEth,
            address priceFeedBtc,
            address wEth,
            address wBtc,

        ) = helperConfig.activeNetworkConfig();
        s_priceFeedEth = priceFeedEth;
        s_priceFeedBtc = priceFeedBtc;
        s_wEth = wEth;
        s_wBtc = wBtc;
        vm.prank(USER);
        DecentralizedStablecoin usdd = new DecentralizedStablecoin(USER);
        vm.prank(USER);
        DSCEngine dscEngine = new DSCEngine(
            priceFeedEth,
            priceFeedBtc,
            wEth,
            wBtc,
            address(usdd)
        );
        vm.prank(USER);
        usdd.transferOwnership(address(dscEngine));
        s_dscEngine = dscEngine;
    }

    //CONSTRUCTOR//
    function testConstructorValues() external view {
        assertEq(s_dscEngine.getSwETH(), s_wEth);
        assertEq(s_dscEngine.getSwBTC(), s_wBtc);
    }
    //DEPOSIT//

    function testRevertFOrDeposit() external {
        vm.expectRevert();
        s_dscEngine.depositCollateral(address(0), 100);
        vm.expectRevert();
        s_dscEngine.depositCollateral(s_wEth, 0);
    }

    function testCorrectDeposit() external {
        vm.prank(USER);
        ERC20Mock(s_wEth).mint(USER, 200);
        uint256 total = ERC20Mock(s_wEth).balanceOf(USER);
        console.log(total);
        vm.prank(USER);
        ERC20Mock(s_wEth).approve(address(s_dscEngine), 100);
        vm.prank(USER);
        s_dscEngine.depositCollateral(s_wEth, 100);

        uint256 balanceCollateralInTokens = s_dscEngine
            .getBalanceCollateralInTokens(USER, s_wEth);

        assert(balanceCollateralInTokens == 100);
        assert(ERC20Mock(s_wEth).balanceOf(address(s_dscEngine)) == 100);
    }
}
