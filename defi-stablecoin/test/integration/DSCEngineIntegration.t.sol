// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../src/DecentralizedStablecoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSCEngine} from "../../script/DeployDSCEngine.s.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.t.sol";

contract DSCEngineIntegration is Test {
    DSCEngine public s_dscEngine;
    DecentralizedStablecoin public s_usdd;
    HelperConfig public s_helper;

    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;

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
    uint256 private constant AMOUNT_DEPOSIT = 0.07 ether;
    uint256 private constant MORE_THAN_HALF_COLLATERAL_VALUE = 1016e17;
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
    }

    //CONSTRUCTOR//
    function testConstructorValuesIntegration() external view {
        assertEq(s_dscEngine.getSwETH(), wETH);
        assertEq(s_dscEngine.getSwBTC(), wBTC);
    }
    //PRICE FEED TEST//
    //getCollateralValueinUsd//
    function testGetCollateralValueinUsd() external deposit {
        uint256 collaterallValueExpected = AMOUNT_DEPOSIT * 2900;
        uint256 collaterallValueActual = s_dscEngine.getCollateralValueinUsd(
            USER
        );

        assertEq(collaterallValueExpected, collaterallValueActual);
    }

    //getTokenAmountFromUsdValue()//
    function testCorrectAmountOfTokens() external view {
        //La keyword ether consigue representar el numero que le indequemos en 1e18 , es decir en WEI
        //En este caso, queremos representar unidades de stablecoin por lo que nos vale usar esta especificacion.
        uint256 usdAmountOfDebtinWei = 100 ether;
        uint256 expectedValue = usdAmountOfDebtinWei / 2900; //Obtenemos el value en 1e18
        console.log(expectedValue);

        uint256 actualValue = s_dscEngine.getTokenAmountFromUsdValue(wETH, 100);
        console.log(actualValue);

        assertEq(expectedValue, actualValue);
    }
    function testCorrectAmountOfTokensBTC() external view {
        //La keyword ether consigue representar el numero que le indequemos en 1e18 , es decir en WEI
        //En este caso, queremos representar unidades de stablecoin por lo que nos vale usar esta especificacion.
        uint256 usdAmountOfDebtinWei = 200 ether;
        uint256 expectedValue = (usdAmountOfDebtinWei) / 60000; //
        console.log(expectedValue);

        uint256 actualValue = s_dscEngine.getTokenAmountFromUsdValue(wBTC, 200);
        console.log(actualValue);

        assertEq(expectedValue, actualValue);
    }
    function testGetUsdValueETH() public view {
        uint256 ethAmount = 15e18;
        //15e18 * 2900/ETH = 43500e18
        uint256 expectedUsd = 43500e18;
        uint256 priceEthNow = s_dscEngine.getUsdValueETH(ethAmount);
        console.log(priceEthNow);
        assertEq(expectedUsd, priceEthNow);
    }
    function testGetUsdValueBTC() public view {
        uint256 btcAmount = 2e18;
        //1e18 * 60000/1 = 60000e18
        uint256 expectedUsd = 120000e18;
        uint256 priceBtcNow = s_dscEngine.getUsdValueBTC(btcAmount);
        console.log(priceBtcNow);
        assertEq(expectedUsd, priceBtcNow);
    }

    //DEPOSITCOLLATERAL//

    function testRevertFOrDepositIntegrations() external {
        vm.expectRevert(DSCEngine.DSCEngine__CantBeAddressZero.selector);
        s_dscEngine.depositCollateral(address(0), 100);
        vm.expectRevert(DSCEngine.DSCEngine__CantBeZero.selector);
        s_dscEngine.depositCollateral(wETH, 0);
    }

    function testCorrectDepositIntegration() external {
        vm.prank(USER);
        ERC20Mock(wETH).mint(USER, AMOUNT_DEPOSIT);
        uint256 total = ERC20Mock(wETH).balanceOf(USER);
        console.log(total);
        vm.prank(USER);
        ERC20Mock(wETH).approve(address(s_dscEngine), AMOUNT_DEPOSIT);
        vm.prank(USER);
        s_dscEngine.depositCollateral(wETH, AMOUNT_DEPOSIT);

        uint256 balanceCollateralInTokens = s_dscEngine
            .getBalanceCollateralInTokens(USER, wETH);
        console.log("Esto es su balance en mapping", balanceCollateralInTokens);

        assert(balanceCollateralInTokens == AMOUNT_DEPOSIT);
        assert(
            ERC20Mock(wETH).balanceOf(address(s_dscEngine)) == AMOUNT_DEPOSIT
        );
    }
    function testEmitEventCorrectlyDuringDeposit()
        external
        mintWethTokensToUSer
    {
        vm.expectEmit(true, true, true, false, address(s_dscEngine));
        emit DSCEngine.CollateralAdded(USER, wETH, 200);
        vm.prank(USER);
        s_dscEngine.depositCollateral(wETH, 200);
    }

    modifier mintWethTokensToUSer() {
        vm.prank(USER);
        ERC20Mock(wETH).mint(USER, AMOUNT_DEPOSIT);
        vm.prank(USER);
        ERC20Mock(wETH).approve(address(s_dscEngine), AMOUNT_DEPOSIT);

        _;
    }

    function testDepositAndMint() external mintWethTokensToUSer {
        vm.startPrank(USER);
        s_dscEngine.depositCollateralAndMintUSDD(wETH, AMOUNT_DEPOSIT, 50);
        uint256 balanceCollateralInTokens = s_dscEngine
            .getBalanceCollateralInTokens(USER, wETH);

        assert(balanceCollateralInTokens == AMOUNT_DEPOSIT);
        assert(
            ERC20Mock(wETH).balanceOf(address(s_dscEngine)) == AMOUNT_DEPOSIT
        );
        assert(s_usdd.balanceOf(address(USER)) == 50);
    }
    //REDEEMCOLLATERAL//

    modifier deposit() {
        vm.startPrank(USER);
        ERC20Mock(wETH).mint(USER, AMOUNT_DEPOSIT);
        ERC20Mock(wETH).approve(address(s_dscEngine), AMOUNT_DEPOSIT);
        s_dscEngine.depositCollateral(wETH, AMOUNT_DEPOSIT);
        vm.stopPrank();
        _;
    }
    modifier depositBTC() {
        vm.startPrank(USER);
        ERC20Mock(wBTC).mint(USER, 3 ether);
        ERC20Mock(wBTC).approve(address(s_dscEngine), 3 ether);
        s_dscEngine.depositCollateral(wBTC, 3 ether);
        vm.stopPrank();
        _;
    }
    modifier depositAndMint() {
        vm.startPrank(USER);
        ERC20Mock(wETH).mint(USER, AMOUNT_DEPOSIT);
        ERC20Mock(wETH).approve(address(s_dscEngine), AMOUNT_DEPOSIT);
        s_dscEngine.depositCollateralAndMintUSDD(wETH, AMOUNT_DEPOSIT, 50);
        vm.stopPrank();
        _;
    }
    function testRedeemCollateralRevert() external deposit {
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__CantBeAddressZero.selector);
        s_dscEngine.redeemCollateral(address(0), 50);
        vm.expectRevert(DSCEngine.DSCEngine__CantBeZero.selector);
        s_dscEngine.redeemCollateral(wETH, 0);
        vm.expectRevert(DSCEngine.DCSEngine__NotAllowedTokenToFund.selector);
        s_dscEngine.redeemCollateral(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            50
        );
    }

    function testRedeemCollateralPrivateUpdatingBalance() external deposit {
        vm.startPrank(USER);
        uint256 startingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wETH
        );
        console.log(startingBalance);

        s_dscEngine.redeemCollateral(wETH, AMOUNT_DEPOSIT);
        uint256 endingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wETH
        );
        console.log(endingBalance);

        assertEq(startingBalance - AMOUNT_DEPOSIT, endingBalance);
    }
    function testRedeemBTC() external depositBTC {
        vm.startPrank(USER);
        uint256 startingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wBTC
        );
        console.log(startingBalance);

        s_dscEngine.redeemCollateral(wBTC, 2 ether);
        uint256 endingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wBTC
        );
        console.log(endingBalance);

        assertEq(startingBalance - 2 ether, endingBalance);
    }
    function testExpectRevertWhenRedeemingMoreThanYouHave()
        external
        depositBTC
    {
        vm.startPrank(USER);

        vm.expectRevert(
            DSCEngine
                .DSCEngine__NotPossibleToRedeemMoreThanCollateralBalance
                .selector
        );
        s_dscEngine.redeemCollateral(wBTC, 5 ether);
    }
    //FUZZ
    function testRedeemBTCFuzz(uint256 _amountToRedeem) external depositBTC {
        vm.startPrank(USER);

        uint256 startingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wBTC
        );
        console.log(startingBalance);
        _amountToRedeem = bound(_amountToRedeem, 1, startingBalance);
        s_dscEngine.redeemCollateral(wBTC, _amountToRedeem);
        uint256 endingBalance = s_dscEngine.getBalanceCollateralInTokens(
            USER,
            wBTC
        );
        console.log(endingBalance);

        assertEq(startingBalance - _amountToRedeem, endingBalance);
    }

    function testRedeemCollateralEmitEvent() external deposit {
        vm.startPrank(USER);
        vm.expectEmit(true, true, true, true, address(s_dscEngine));
        emit DSCEngine.CollateralRedeemed(USER, USER, wETH, 200);
        s_dscEngine.redeemCollateral(wETH, 200);
        vm.stopPrank();
    }

    function testCorrectTransfer() external deposit {
        vm.startPrank(USER);
        uint256 startingBalanceOfUSER = ERC20Mock(wETH).balanceOf(USER);
        s_dscEngine.redeemCollateral(wETH, 200);
        uint256 endingBalanceOfUSER = ERC20Mock(wETH).balanceOf(USER);
        assertEq(startingBalanceOfUSER + 200, endingBalanceOfUSER);
        vm.stopPrank();
    }
    //_revertIfHealthFactorIsBroken//

    function testRevertWhenHealthFactorBroken() external deposit {
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__YouAreUnderCollaterized.selector);

        s_dscEngine.mintUSDD(MORE_THAN_HALF_COLLATERAL_VALUE); // just exactly the limit to be undervolateralized
    }
    // function testRevertWhenHealthFactorBrokenFuzz(
    //     uint256 _amount
    // ) external deposit {
    //     _amount = bound(_amount, 1, AMOUNT_DEPOSIT / 2);
    //     vm.startPrank(USER);
    //     vm.expectRevert(DSCEngine.DSCEngine__YouAreUnderCollaterized.selector);
    //     s_dscEngine.mintUSDD(_amount);
    // }
    //burnUSDD//
    function testCantBeZeroAmount() external {
        vm.prank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__CantBeZero.selector);
        s_dscEngine.burnUSDD(0);
    }

    function testBurnUsddPrivateUpdatingBalance() external depositAndMint {
        vm.startPrank(USER);
        uint256 startingBalance = s_dscEngine.getSUSDDMinted(USER);
        s_usdd.approve(address(s_dscEngine), 50);
        s_dscEngine.burnUSDD(50);
        uint256 endingBalance = s_dscEngine.getSUSDDMinted(USER);
        assert(startingBalance == endingBalance + startingBalance);
    }
    function testBurnUsddEmitEvent() external depositAndMint {
        vm.startPrank(USER);
        s_usdd.approve(address(s_dscEngine), 50);
        vm.expectEmit(true, true, false, false, address(s_dscEngine));
        emit DSCEngine.UsddBurned(USER, 50);
        s_dscEngine.burnUSDD(50);
        vm.stopPrank();
    }
    function testProveThatTokensAreBurned() external depositAndMint {
        vm.startPrank(USER);

        s_usdd.approve(address(s_dscEngine), 50);
        s_dscEngine.burnUSDD(50);
        assertEq(s_usdd.balanceOf(address(s_dscEngine)), 0);
        vm.stopPrank();
    }

    //redeemCollateralAndGiveBackUSDD//

    function testRedeemCollateralAndGiveBackUSDD() external depositAndMint {
        vm.startPrank(USER);

        s_usdd.approve(address(s_dscEngine), 50);
        s_dscEngine.redeemCollateralAndGiveBackUSDD(wETH, 200, 50);

        assert(s_dscEngine.getSUSDDMinted(USER) == 0);
        assert(ERC20Mock(wETH).balanceOf(USER) == 200);
        assert(s_usdd.balanceOf(address(s_dscEngine)) == 0);
    }

    //Liquidate Fn//

    function testLiquidateHealthFactorOk() external depositAndMint {
        vm.startPrank(LIQUIDATOR);
        vm.expectRevert(DSCEngine.DSCEngine__HealthFactorOk.selector);
        s_dscEngine.liquidate(wETH, USER, 50);
    }

    function testLiquidateWorksGood() external {
        vm.startPrank(USER);
        ERC20Mock(wETH).mint(USER, AMOUNT_DEPOSIT);
        ERC20Mock(wETH).approve(address(s_dscEngine), AMOUNT_DEPOSIT);
        s_dscEngine.depositCollateralAndMintUSDD(wETH, AMOUNT_DEPOSIT, 50);
        uint256 balanceUSDDUser = s_usdd.balanceOf(USER);
        console.log("Esto es balance the USER en USDD", balanceUSDDUser);
        vm.stopPrank();
        //Habilitamos al owner del stableCoins para mintear al nuevo usuario LIQUIDATOR
        vm.prank(address(s_dscEngine));
        s_usdd.mint(LIQUIDATOR, 100);
        uint256 balanceUSDD = s_usdd.balanceOf(LIQUIDATOR);
        console.log("Esto es balance the LIQUIDATOR", balanceUSDD);

        uint256 health = s_dscEngine.getHealthFactor(USER);
        console.log("Health", health);

        //vamos a actualizar el price de priceFeed para simular que ha bajado 1000$ por ETH
        //Luego LIQUIDATOR va a ejecutar liquidate
        vm.startPrank(LIQUIDATOR);
        s_priceFeedETH.updateAnswer(1000e8);
        health = s_dscEngine.getHealthFactor(USER);
        console.log("Health 2 ", health);
        uint256 startingBalanceCollateralUSER = s_dscEngine
            .getBalanceCollateralInTokens(USER, wETH);

        s_usdd.approve(address(s_dscEngine), 50);
        s_dscEngine.liquidate(wETH, USER, 50);
        uint256 finalBalanceOfCollateralLIQUIDATOR = ERC20Mock(wETH).balanceOf(
            LIQUIDATOR
        );
        uint256 endingBalanceCollateralUSER = s_dscEngine
            .getBalanceCollateralInTokens(USER, wETH);

        uint256 endingBalanceOfUSDDDLIQUIDATOR = s_usdd.balanceOf(LIQUIDATOR);
        assertEq(
            endingBalanceCollateralUSER,
            startingBalanceCollateralUSER - finalBalanceOfCollateralLIQUIDATOR
        );
        assertEq(finalBalanceOfCollateralLIQUIDATOR, 55000000000000000);
        assertEq(endingBalanceOfUSDDDLIQUIDATOR, balanceUSDD - 50);
    }

    function testDeLamuerte() public deposit {
        vm.startPrank(USER);
        s_dscEngine.mintUSDD(100);

        vm.stopPrank();
    }
    //TODO It will need do decrease the healtfactor.
    /*function testLiquidateDSCEngine__HealthNotImproved()
        external
        depositAndMint
    {
        vm.prank(address(s_dscEngine));
        s_usdd.mint(LIQUIDATOR, 100);

        vm.startPrank(LIQUIDATOR);
        s_priceFeedETH.updateAnswer(1000e8);
        s_usdd.approve(address(s_dscEngine), 20);
        s_dscEngine.liquidate(wETH, USER, 20);
    }*/

    //GetHeathFactor

    function testGetHealthFactor() external mintWethTokensToUSer {
        vm.startPrank(USER);
        s_dscEngine.depositCollateralAndMintUSDD(wETH, AMOUNT_DEPOSIT, 50);

        uint256 healthFactor = s_dscEngine.getHealthFactor(USER);
        console.log(healthFactor);
    }

    //MINTUSDD

    function testMintCorrectlyUsdd() external deposit {
        uint256 balance = s_dscEngine.getBalanceCollateralInTokens(USER, wETH);
        console.log("Esto es balance", balance);
        // uint256 usdValueForBtc = s_dscEngine.getUsdValueBTC(
        //     s_dscEngine.getBalanceCollateralInTokens(USER, wBTC)
        // );
        // console.log("Esto es balance", usdValueForBtc);
        uint256 balanceInUsd = s_dscEngine.getCollateralValueinUsd(USER);
        console.log("Esto es el Balance en usd1", balanceInUsd);
        // uint256 usdValueForEther = s_dscEngine.getUsdValueETH(balance);
        // console.log("Esto es el Balance en usd", usdValueForEther);
        // (uint256 totalMintedUSDD, uint256 collateralValueInUSD) = s_dscEngine
        //     ._getAccountInformation(USER);
        // console.log("Esta es la fn que falla: ", totalMintedUSDD);
        // console.log("Esta es la fn que falla: ", collateralValueInUSD);
        vm.startPrank(USER);
        s_dscEngine.mintUSDD(50);
        s_dscEngine.mintUSDD(50);
    }
}
