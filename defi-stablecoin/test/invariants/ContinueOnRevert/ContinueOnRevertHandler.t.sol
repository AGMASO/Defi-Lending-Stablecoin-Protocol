// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {DSCEngine} from "../../../src/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../../src/DecentralizedStablecoin.sol";

import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "../../mocks/MockV3Aggregator.t.sol";

//! KEY for this handler:  No se podrá usar redeemCollateral si no hay Collateral deposited.
contract ContinueOnRevertHandler is Test {
    DSCEngine s_dscEngine;
    DecentralizedStablecoin s_Usdd;
    MockV3Aggregator public s_priceFeedETH;
    MockV3Aggregator public s_priceFeedBTC;

    uint256 public timesMintCalled = 0;
    uint256 public constant MAX_DEPOSIT_SIZE = type(uint96).max;
    address public USER = makeAddr("user");
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant PRECISION = 1e18;
    address[] public s_collaterlDepositors;

    constructor(DSCEngine _DscEngine, DecentralizedStablecoin _usdd) {
        s_dscEngine = _DscEngine;
        s_Usdd = _usdd;
        vm.deal(USER, STARTING_VALUE);
        s_priceFeedETH = MockV3Aggregator(s_dscEngine.getSpriceFeedETH());
        s_priceFeedBTC = MockV3Aggregator(s_dscEngine.getSpriceFeedBTC());
    }
    //!en los Handler SC , todos los parametros que se indiquen en la Fn van a ser randomizados.Importante saber

    function depositCollateral(
        uint256 _collateralSeed,
        uint256 _amount
    ) public {
        address validTokenCollateral = _getValidCollateralAddress(
            _collateralSeed
        );
        //!Usamos bound para limitar overflows and underflows errors, ya que si enviamos
        //! 0 amount revertira nuestra Fn, y si enviamos un numero muy grande, dara fallo por overflow.
        uint256 validAmountBounded = bound(_amount, 1, MAX_DEPOSIT_SIZE);
        vm.startPrank(msg.sender);
        ERC20Mock(validTokenCollateral).mint(msg.sender, validAmountBounded);
        ERC20Mock(validTokenCollateral).approve(
            address(s_dscEngine),
            validAmountBounded
        );
        s_dscEngine.depositCollateral(validTokenCollateral, validAmountBounded);
        s_collaterlDepositors.push(msg.sender);

        vm.stopPrank();
    }

    function redeemCollateral(
        uint256 _collateralSeed,
        uint256 _amountToRedeem
    ) public {
        address validTokenCollateral = _getValidCollateralAddress(
            _collateralSeed
        );
        //Escogemos a una address dentro del array de depositors randomly.
        address[] memory depositors = s_collaterlDepositors;
        if (depositors.length == 0) {
            return;
        }
        uint256 indexOfDepositor = _collateralSeed % depositors.length;
        address depositorToRedeem = depositors[indexOfDepositor];

        uint256 maxAmountPossibleToRedeem = s_dscEngine
            .getBalanceCollateralInTokens(
                depositorToRedeem,
                validTokenCollateral
            );
        console.log(
            "Esto es el balance de collateral",
            maxAmountPossibleToRedeem
        );
        if (maxAmountPossibleToRedeem == 0) {
            return;
        }

        _amountToRedeem = bound(_amountToRedeem, 0, maxAmountPossibleToRedeem);
        console.log("Esto es el bound", _amountToRedeem);
        if (_amountToRedeem == 0) {
            return;
        }
        (uint256 totalMintedUSDD, uint256 collateralValueInUSD) = s_dscEngine
            ._getAccountInformation(depositorToRedeem);
        if (
            (totalMintedUSDD * PRECISION) * 2 > collateralValueInUSD * PRECISION
        ) {
            return;
        }
        vm.startPrank(depositorToRedeem);
        s_dscEngine.redeemCollateral(validTokenCollateral, _amountToRedeem);
        vm.stopPrank();
    }

    function mintUSDD(uint256 _collateralSeed, uint256 _amountToMint) public {
        //Escogemos a una address dentro del array de depositors randomly.
        address[] memory depositors = s_collaterlDepositors;
        if (depositors.length == 0) {
            return;
        }
        uint256 indexOfDepositor = _collateralSeed % depositors.length;
        address depositorToRedeem = depositors[indexOfDepositor];
        (uint256 totalMintedUSDD, uint256 collateralValueInUSD) = s_dscEngine
            ._getAccountInformation(depositorToRedeem);

        int256 maxUsddToMint = (int256(collateralValueInUSD) / 2) -
            int256(totalMintedUSDD);

        if (maxUsddToMint == 0) {
            return;
        }

        _amountToMint = bound(_amountToMint, 0, uint256(maxUsddToMint));
        if (_amountToMint == 0) {
            return;
        }

        vm.startPrank(depositorToRedeem);
        s_dscEngine.mintUSDD(_amountToMint);
        timesMintCalled++;
        vm.stopPrank();
    }

    //Liquidate//

    function liquidate(uint256 _collateralSeed, uint256 _debtToCover) public {
        //Escogemos a una address dentro del array de depositors randomly.
        address[] memory depositors = s_collaterlDepositors;
        if (depositors.length == 0) {
            return;
        }
        uint256 indexOfDepositor = _collateralSeed % depositors.length;
        //Address User to liquidate
        address depositorToLiquidate = depositors[indexOfDepositor];
        //TokenCOllateral picked
        address validTokenCollateral = _getValidCollateralAddress(
            _collateralSeed
        );
        // //Update of the priceFeed
        // s_priceFeedETH.updateAnswer(1000e8);
        // s_priceFeedBTC.updateAnswer(40000e8);

        //Bounding _debtToCover
        uint256 totalMintedUSDD = s_dscEngine.getSUSDDMinted(
            depositorToLiquidate
        );
        if (totalMintedUSDD == 0) {
            return;
        }
        _debtToCover = bound(_debtToCover, 0, totalMintedUSDD);
        if (_debtToCover == 0) {
            return;
        }

        uint256 health = s_dscEngine.getHealthFactor(depositorToLiquidate);
        console.log("Esto es healfactor en Liquidate", health);
        if (health >= MIN_HEALTH_FACTOR) {
            return;
        }

        //Minting USDD for the Liquidator in this case USER
        vm.prank(address(s_dscEngine));
        s_Usdd.mint(USER, MAX_DEPOSIT_SIZE);

        vm.startPrank(USER);
        //s_Usdd.approve(address(s_dscEngine), _debtToCover);
        s_dscEngine.liquidate(
            validTokenCollateral,
            depositorToLiquidate,
            _debtToCover
        );
        vm.stopPrank();
    }

    //GetFunctions//
    function _getValidCollateralAddress(
        uint256 _collateralSeed
    ) internal view returns (address validToken) {
        if (_collateralSeed % 2 == 0) {
            return s_dscEngine.getSwETH();
        }
        return s_dscEngine.getSwBTC();
    }
}
