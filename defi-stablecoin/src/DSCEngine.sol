// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {console} from "forge-std/Script.sol";
import {DecentralizedStablecoin} from "./DecentralizedStablecoin.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {OracleLib} from "./libraries/OracleLib.sol";

/// @title DSCENGINE Smart Contract
/// @notice The contract ensures a 1:1 peg between the USDD token and USD.
/// @notice It is similar to DAI but without a DAO, fees, and is backed only by wBTC and wETH.
/// @notice It provides functionality for minting, redeeming, depositing, and withdrawing collateral.
/// @dev The system is designed to remain over-collateralized to ensure stability.

interface IDSCEngine {
    /// @notice Deposits collateral and mints USDD in a single transaction.
    function depositCollateralAndMintUSDD(address, uint256, uint256) external;

    /// @notice Deposits collateral into the system.
    function depositCollateral(address, uint256) external;

    /// @notice Redeems collateral from the system.
    function redeemCollateral(address, uint256) external;

    /// @notice Redeems collateral and simultaneously burns USDD.
    function redeemCollateralAndGiveBackUSDD(
        address,
        uint256,
        uint256
    ) external;

    /// @notice Mints USDD against deposited collateral.
    function mintUSDD(uint256) external;

    /// @notice Burns USDD to improve the health factor or settle debt.
    function burnUSDD(uint256) external;

    /// @notice Liquidates an under-collateralized position.
    function liquidate(address, address, uint256) external;

    /// @notice Retrieves the health factor of a specific user.
    function getHealthFactor(address) external view returns (uint256);
}

contract DSCEngine is IDSCEngine {
    //Mappings//
    mapping(address => mapping(address => uint256))
        private s_balanceCollateralInTokens;

    mapping(address user => uint256 amountUSDDMinted) private s_USDDMinted;

    mapping(address tokenAddress => bool allowed) private tokenAllowance;

    //State variables//
    AggregatorV3Interface private s_priceFeedETH;
    AggregatorV3Interface private s_priceFeedBTC;
    address private s_wETH;
    address private s_wBTC;
    address private immutable i_USDD;

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant FEED_PRECISION = 1e8;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // This means you need to be 200% over-collateralized
    uint256 private constant PRECISION = 1e18;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATION_BONUS = 10;

    //Events//
    event CollateralAdded(
        address indexed sender,
        address indexed tokenAddress,
        uint256 indexed amount
    );
    event CollateralRedeemed(
        address indexed redeemedFrom,
        address indexed redeemedTo,
        address indexed tokenAdress,
        uint256 amount
    );
    event UsddMintedCorrectly(
        address indexed caller,
        address indexed tokenMinted,
        uint256 indexed amountMinted
    );
    event UsddBurned(address indexed burner, uint256 indexed amount);

    //Errors//
    error DSCEngine__CantBeAddressZero();
    error DSCEngine__CantBeZero();
    error DCSEngine__NotAllowedTokenToFund();
    error DSCEngine__SafeTransferError();
    error DSCEngine__MintError();
    error DSCEngine__NotPossibleToRedeemMoreThanCollateralBalance();
    error DSCEngine__YouAreUnderCollaterized();
    error DSCEngine__BurnError();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__AmountToLiquidateExeceedTheBalanceOfClient();
    error DSCEngine__HealthNotImproved();

    //Types//
    using OracleLib for AggregatorV3Interface;

    //Modifiers//
    modifier CantBeAddressZero(address _tokenAddress) {
        if (_tokenAddress == address(0)) {
            revert DSCEngine__CantBeAddressZero();
        }
        _;
    }
    modifier CantBeZeroAmount(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine__CantBeZero();
        }
        _;
    }

    modifier AllowedTokenToFund(address _tokenAddress) {
        if (tokenAllowance[_tokenAddress] == false) {
            revert DCSEngine__NotAllowedTokenToFund();
        }
        _;
    }

    ///////////////////
    // Constructor
    ///////////////////

    /// @notice Initializes the DSCEngine contract with essential parameters.
    /// @param _priceFeedEth The address of the Chainlink ETH price feed.
    /// @param _priceFeedWBTC The address of the Chainlink WBTC price feed.
    /// @param wETH The address of the wETH token.
    /// @param wBTC The address of the wBTC token.
    /// @param _USDD The address of the USDD stablecoin.
    constructor(
        address _priceFeedEth,
        address _priceFeedWBTC,
        address wETH,
        address wBTC,
        address _USDD
    ) {
        s_priceFeedETH = AggregatorV3Interface(_priceFeedEth);
        s_wETH = wETH;
        tokenAllowance[wETH] = true;
        s_priceFeedBTC = AggregatorV3Interface(_priceFeedWBTC);
        s_wBTC = wBTC;
        tokenAllowance[wBTC] = true;
        i_USDD = _USDD;
    }

    ///////////////////
    // External Functions
    ///////////////////

    /// @notice Deposits collateral and mints USDD in a single transaction.
    /// @param _tokenAddress The token address of the collateral.
    /// @param _amountofCollateral The amount of collateral to deposit.
    /// @param _amountUSDDToMint The amount of USDD to mint.
    function depositCollateralAndMintUSDD(
        address _tokenAddress,
        uint256 _amountofCollateral,
        uint256 _amountUSDDToMint
    ) external {
        depositCollateral(_tokenAddress, _amountofCollateral);
        mintUSDD(_amountUSDDToMint);
    }

    /// @notice Redeems collateral while ensuring the health factor remains above 1.
    /// @param tokenCollateral The token address of the collateral.
    /// @param amountToRedeem The amount of collateral to redeem.
    function redeemCollateral(
        address tokenCollateral,
        uint256 amountToRedeem
    )
        public
        CantBeAddressZero(tokenCollateral)
        CantBeZeroAmount(amountToRedeem)
        AllowedTokenToFund(tokenCollateral)
    {
        _redeemCollateral(
            tokenCollateral,
            msg.sender,
            msg.sender,
            amountToRedeem
        );
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /// @notice Redeems collateral and burns USDD in a single transaction.
    /// @param tokenCollateral The token address of the collateral.
    /// @param amountOfCollateralToRedeem The amount of collateral to redeem.
    /// @param amountToUssdToBurn The amount of USDD to burn.
    function redeemCollateralAndGiveBackUSDD(
        address tokenCollateral,
        uint256 amountOfCollateralToRedeem,
        uint256 amountToUssdToBurn
    ) external {
        burnUSDD(amountToUssdToBurn);
        redeemCollateral(tokenCollateral, amountOfCollateralToRedeem);
    }

    /// @notice Burns USDD to improve the health factor or reduce debt.
    /// @param amountToBurn The amount of USDD to burn.
    function burnUSDD(
        uint256 amountToBurn
    ) public CantBeZeroAmount(amountToBurn) {
        _burnUSDD(amountToBurn, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender); //Ejemplo para auditar seguridad y optimizar quitandolo ya que al quemar USDD nunca va a romper el HelathFactor
    }

    /// @notice Liquidates an under-collateralized position.
    /// @param collateralTokenAddress The token address of the collateral.
    /// @param user The address of the under-collateralized user.
    /// @param debtToCover The amount of USDD to burn to cover the user's debt.
    function liquidate(
        address collateralTokenAddress,
        address user,
        uint256 debtToCover
    )
        external
        CantBeAddressZero(collateralTokenAddress)
        CantBeZeroAmount(debtToCover)
    {
        //checks
        uint256 startingHealthFactor = _healthFactor(user);
        if (startingHealthFactor >= MIN_HEALTH_FACTOR) {
            revert DSCEngine__HealthFactorOk();
        }

        uint256 tokenAmountToGetAfterDebtCovered = getTokenAmountFromUsdValue(
            collateralTokenAddress,
            debtToCover
        );
        console.log(
            "Esto es cuantos tokens to get ",
            tokenAmountToGetAfterDebtCovered
        );
        uint256 bonus = (tokenAmountToGetAfterDebtCovered * LIQUIDATION_BONUS) /
            100;
        uint256 totalAmountYield = tokenAmountToGetAfterDebtCovered + bonus;
        console.log("Esto es el totalAmountTOYield", totalAmountYield);

        //Interactions
        _redeemCollateral(
            collateralTokenAddress,
            user,
            msg.sender,
            totalAmountYield
        );

        _burnUSDD(debtToCover, user, msg.sender);

        //Again checks
        uint256 endingHealthFactor = _healthFactor(user);
        if (endingHealthFactor <= startingHealthFactor) {
            revert DSCEngine__HealthNotImproved();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    ///////////////////
    // Public Functions
    ///////////////////

    /// @notice Deposits collateral into the system.
    /// @dev This function increases the user's collateral balance and transfers the specified amount of tokens to the contract.
    ///      It emits a `CollateralAdded` event upon successful deposit.
    /// @param _tokenAddress The ERC20 token address of the collateral being deposited.
    /// @param _amount The amount of collateral to deposit.
    function depositCollateral(
        address _tokenAddress,
        uint256 _amount
    )
        public
        CantBeAddressZero(_tokenAddress)
        CantBeZeroAmount(_amount)
        AllowedTokenToFund(_tokenAddress)
    {
        s_balanceCollateralInTokens[msg.sender][_tokenAddress] += _amount;
        emit CollateralAdded(msg.sender, _tokenAddress, _amount);

        bool success = IERC20(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (!success) {
            revert DSCEngine__SafeTransferError();
        }
    }

    /// @notice Mints USDD stablecoins against the user's deposited collateral.
    /// @dev The function first checks if the health factor will remain above the minimum threshold after minting.
    ///      If the health factor is violated, the mint operation is reverted.
    ///      It emits a `UsddMintedCorrectly` event upon successful minting.
    /// @param _amountUSDDToMint The amount of USDD stablecoins to mint.
    function mintUSDD(
        uint256 _amountUSDDToMint
    ) public CantBeZeroAmount(_amountUSDDToMint) {
        //CEI
        //Checks
        //!Primero anadimos el _amountUSDDToMint al mapping, esto lo hacemos para poder calcular si el HealthFactor
        //! se rompe o no. Si no se rompe, dejamos que la function siga y envie los stablecoins minteados
        //! En el caso de que se rompa, entonces reviertira toda la Fn y el mapping no quedara actualizado.
        s_USDDMinted[msg.sender] += _amountUSDDToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        //Effects

        emit UsddMintedCorrectly(msg.sender, i_USDD, _amountUSDDToMint);
        //Interactions
        bool minted = DecentralizedStablecoin(i_USDD).mint(
            msg.sender,
            _amountUSDDToMint
        );
        if (!minted) {
            revert DSCEngine__MintError();
        }
    }

    ///////////////////
    // Internal & Private Functions
    ///////////////////

    /// @notice Burns USDD and updates the system state.
    /// @dev This is a low-level function that requires health factor checks externally.
    /// @param amountToBurn The amount of USDD to burn.
    /// @param onBehalfOf The user whose debt is being reduced.
    /// @param usddFrom The address from which USDD is taken.
    function _burnUSDD(
        uint256 amountToBurn,
        address onBehalfOf,
        address usddFrom
    ) private {
        s_USDDMinted[onBehalfOf] -= amountToBurn;
        emit UsddBurned(usddFrom, amountToBurn);

        bool success = DecentralizedStablecoin(i_USDD).transferFrom(
            usddFrom,
            address(this),
            amountToBurn
        );
        if (!success) {
            revert DSCEngine__SafeTransferError();
        }
        DecentralizedStablecoin(i_USDD).burn(amountToBurn);
    }

    /// @notice Internal function to redeem collateral.
    function _redeemCollateral(
        address tokenCollateral,
        address liquidatedUser,
        address callerLiquidation,
        uint256 amountToRedeem
    ) private {
        uint256 balancePriorSubAmountToRedeem = s_balanceCollateralInTokens[
            liquidatedUser
        ][tokenCollateral];

        console.log(
            "Esto es el Balance del token colateral escogido",
            balancePriorSubAmountToRedeem
        );
        if (amountToRedeem > balancePriorSubAmountToRedeem) {
            revert DSCEngine__NotPossibleToRedeemMoreThanCollateralBalance();
        }

        s_balanceCollateralInTokens[liquidatedUser][
            tokenCollateral
        ] -= amountToRedeem;
        console.log(
            "Esto es el balance despues de restar el amountToRedeem",
            s_balanceCollateralInTokens[liquidatedUser][tokenCollateral]
        );
        //Effects
        emit CollateralRedeemed(
            liquidatedUser,
            callerLiquidation,
            tokenCollateral,
            amountToRedeem
        );
        //Interactions
        bool success = IERC20(tokenCollateral).transfer(
            callerLiquidation,
            amountToRedeem
        );
        if (!success) {
            revert DSCEngine__SafeTransferError();
        }
    }

    /// @notice Retrieves the total minted USDD and the collateral value in USD for a specific user.
    /// @dev This function aggregates the total USDD minted by the user and calculates the USD value of their collateral.
    /// @param user The address of the user whose account information is being queried.
    /// @return totalMintedUSDD The total amount of USDD minted by the user.
    /// @return collateralValueInUSD The total value of the user's collateral in USD.
    function _getAccountInformation(
        address user
    )
        public
        view
        returns (uint256 totalMintedUSDD, uint256 collateralValueInUSD)
    {
        totalMintedUSDD = s_USDDMinted[user];
        collateralValueInUSD = getCollateralValueinUsd(user);
    }

    /// @notice Get a factor uint256 indicating how close is the user to liquidation in relation
    /// @notice with the collateral and the minted USDD that he has
    function _healthFactor(address user) private view returns (uint256) {
        (
            uint256 totalMintedUSDD,
            uint256 collateralValueInUSD
        ) = _getAccountInformation(user);
        console.log("Esto es totalMintedUSDD", totalMintedUSDD);
        console.log("Esto es collateralValueInUSD", collateralValueInUSD);

        if (totalMintedUSDD == 0) {
            return MIN_HEALTH_FACTOR;
        }

        uint256 collateralAdjustedForThreshold = (collateralValueInUSD *
            LIQUIDATION_THRESHOLD) / 100;
        console.log(
            "Esto es collateralAdjustedForThreshold",
            collateralAdjustedForThreshold
        );
        uint256 healthFactor = ((collateralAdjustedForThreshold) /
            totalMintedUSDD);

        console.log("Esto es el HealthFactor: ", healthFactor);
        return healthFactor;
    }
    function _revertIfHealthFactorIsBroken(address user) internal view {
        if (_healthFactor(user) < MIN_HEALTH_FACTOR) {
            revert DSCEngine__YouAreUnderCollaterized();
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function getHealthFactor(address user) external view returns (uint256) {
        return _healthFactor(user);
    }

    function getTokenAmountFromUsdValue(
        address tokenAddress,
        uint256 usdAmountOfDebt
    ) public view returns (uint256 TokenAmountFromUsdValue) {
        if (tokenAddress == s_wETH) {
            (, int256 answerETH, , , ) = s_priceFeedETH
                .checkIfOnLatestRoundData();
            return
                (usdAmountOfDebt * PRECISION * PRECISION) /
                (uint256(answerETH) * ADDITIONAL_FEED_PRECISION);
        }

        if (tokenAddress == s_wBTC) {
            (, int256 answerBTC, , , ) = s_priceFeedBTC
                .checkIfOnLatestRoundData();
            return
                (usdAmountOfDebt * PRECISION * PRECISION) /
                (uint256(answerBTC) * ADDITIONAL_FEED_PRECISION);
        }
    }

    function getCollateralValueinUsd(
        address user
    ) public view returns (uint256) {
        uint256 collateralETHAmount = s_balanceCollateralInTokens[user][s_wETH];
        uint256 collateralBTCAmount = s_balanceCollateralInTokens[user][s_wBTC];
        uint256 totalCollateral = getUsdValueETH(collateralETHAmount) +
            getUsdValueBTC(collateralBTCAmount);

        return totalCollateral;
    }
    function getUsdValueETH(uint256 amount) public view returns (uint256) {
        (, int256 answerETH, , , ) = s_priceFeedETH.checkIfOnLatestRoundData();
        return
            ((uint256(answerETH) * ADDITIONAL_FEED_PRECISION) * amount) /
            PRECISION;
    }
    function getUsdValueBTC(uint256 amount) public view returns (uint256) {
        (, int256 answerBTC, , , ) = s_priceFeedBTC.checkIfOnLatestRoundData();
        return
            ((uint256(answerBTC) * ADDITIONAL_FEED_PRECISION) * amount) /
            (PRECISION);
    }

    function getBalanceCollateralInTokens(
        address user,
        address token
    ) public view returns (uint256) {
        return s_balanceCollateralInTokens[user][token];
    }
    function getSUSDDMinted(address user) public view returns (uint256) {
        return s_USDDMinted[user];
    }
    function getSpriceFeedETH() public view returns (address) {
        return address(s_priceFeedETH);
    }
    function getSpriceFeedBTC() public view returns (address) {
        return address(s_priceFeedBTC);
    }
    function getSwETH() public view returns (address) {
        return s_wETH;
    }
    function getSwBTC() public view returns (address) {
        return s_wBTC;
    }
}
