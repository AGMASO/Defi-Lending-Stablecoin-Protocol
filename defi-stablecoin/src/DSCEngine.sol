// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {console} from "forge-std/Script.sol";
import {DecentralizedStablecoin} from "./DecentralizedStablecoin.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {OracleLib} from "./libraries/OracleLib.sol";

/// @title DSCENGINE Smart Contract
/// @author Alejandro G.
/// @notice The contract is designed to maintain the 1 token == to 1$
/// @notice Is similar to DAI but without DAO, no fees and only backed by wBTC and wETH
/// @notice This contract has the logic for de Mining, Redeem as well depositing and withdraw
/// @notice Our DSC system teien que estar siempre overcollaterized. No puede ser posible que
/// @notice el value del collateral sea <= al value del USDD que tenga el cliente.

//! Un metodo para crear nuevos contratos y no olvidarnos de nada de ,o que queremos implementar
//! es crear una Interface donde vamos a Introducir todas las FNs que queremos desarrollar y
//! decir que nuesto SC es esta interface, asi si se nos olvida algo, nos daremos cuenta
interface IDSCEngine {
    function depositCollateralAndMintUSDD(address, uint256, uint256) external;
    function depositCollateral(address, uint256) external;
    function redeemCollateral(address, uint256) external;
    function redeemCollateralAndGiveBackUSDD(
        address,
        uint256,
        uint256
    ) external;
    function mintUSDD(uint256) external;

    //!Nos sirve en el caso de que el cliente, debido a fluctuaciones del precio, tenga poco collateral
    //! para cubrir la posicion de Stablecoin, por lo que usando Burn, eliminara stablecoins y
    //! balanceara su collateral
    function burnUSDD(uint256) external;

    //! Fn para liquidar a personas que esten llegando al undercollateral. Esto se produce cuando el precio
    //! fluctua y el valor del collateral(wBTC o wETH) se acerca a un cirto porcentaje que establecemos
    //! en el systema al valor del USDD que tenga el cliente.
    //!NOTA: Otros podran usar esta fn si encuentran a un cliente undercollaterized. Esto sera un incentivo
    //! del sistema para punish a los clientes que no vigilen que no tienen suficiente collateral para
    //!mantener la posicion y un incentivo para premiar a los usuarios que esten dispuesto a pagar el valor
    //! en USDD de vuelta al systema para obtener el restante del collateral del cliente punished.

    //Ejemplo. pago 100$ en ETH y minteo 50$ en USDD.
    // EL precio de ETH baja y mi collateral value es 74$.
    //Esta estipulado que si baja mas de 25% se liquida.
    //Otro usuario descubre que esta undercollaterized y liquida() al primer usuario recibiendo los 74$ y
    // aportando solo 50$ en USDD, osea que gana 24$.
    function liquidate(address, address, uint256) external;
    function getHealthFactor(address) external view returns (uint256);
}

contract DSCEngine is IDSCEngine {
    mapping(address => mapping(address => uint256))
        private s_balanceCollateralInTokens;
    //!Only the clients that mint Stablecoins will add uint256 to this mapping. This means that only the people
    //! asking for a loan, will applied to this mapping. In other hand, the people who exchange their ETH for
    //! USDD in a exchange, will have nothing to do with this mapping.
    mapping(address user => uint256 amountUSDDMinted) private s_USDDMinted;

    mapping(address tokenAddress => bool allowed) private tokenAllowance;
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
    //EVENTS//
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
    //ERRORS//
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
    //MODIFIERS//
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
    // Functions
    ///////////////////

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

    /*
     * @param _tokenAddress: The ERC20 token address of the collateral you're depositing
     * @param _amount: The amount of collateral you're depositing
     * @param amountDscToMint: The amount of DSC you want to mint
     * @notice This function will deposit your collateral and mint DSC in one transaction
     */
    function depositCollateralAndMintUSDD(
        address _tokenAddress,
        uint256 _amountofCollateral,
        uint256 _amountUSDDToMint
    ) external {
        depositCollateral(_tokenAddress, _amountofCollateral);
        mintUSDD(_amountUSDDToMint);
    }

    /// @notice Allow retire Collateral but in order to do it:
    /// @notice 1. Health factor must be over 1 AFTER collateral is pulled
    /// @param tokenCollateral, address of the token to redeem
    /// @param amountToRedeem, amount to redeem
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
    /*
     * @param tokenCollateral: The ERC20 token address of the collateral you're depositing
     * @param amountOfCollateralToRedeem: The amount of collateral you're depositing
     * @param amountToUssdToBurn: The amount of USDD you want to burn
     * @notice This function will withdraw your collateral and burn DSC in one transaction
     */
    function redeemCollateralAndGiveBackUSDD(
        address tokenCollateral,
        uint256 amountOfCollateralToRedeem,
        uint256 amountToUssdToBurn
    ) external {
        //!Primero quemamos el USDD que quiera el cliente, ya que no afecta a su healfactor
        //! Segundo extraemos el Collateral.
        burnUSDD(amountToUssdToBurn);
        redeemCollateral(tokenCollateral, amountOfCollateralToRedeem);
    }

    /*
     * @notice careful! You'll burn your DSC here! Make sure you want to do this...
     * @dev you might want to use this if you're nervous you might get liquidated and want to just burn
     * you DSC but keep your collateral in.
     */
    function burnUSDD(
        uint256 amountToBurn
    ) public CantBeZeroAmount(amountToBurn) {
        _burnUSDD(amountToBurn, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender); //Ejemplo para auditar seguridad y optimizar quitandolo ya que al quemar USDD nunca va a romper el HelathFactor
    }
    /*
     * @param collateralTokenAddress: The ERC20 token address of the collateral you're using to make the protocol solvent again.
     * This is collateral that you're going to take from the user who is insolvent.
     * In return, you have to burn your USDD to pay off their debt, but you don't pay off your own.
     * @param user: The user who is insolvent. They have to have a _healthFactor below MIN_HEALTH_FACTOR
     * @param debtToCover: The amount of USDD/USD$ you want to burn to cover the user's debt.
     *
     * @notice: You can partially liquidate a user.
     * @notice: You will get a 10% LIQUIDATION_BONUS for taking the users funds.
     * @notice: This function working assumes that the protocol will be roughly 150% overcollateralized in order for this to work.
     * @notice: A known bug would be if the protocol was only 100% collateralized, we wouldn't be able to liquidate anyone.
     * For example, if the price of the collateral plummeted before anyone could be liquidated.
     */
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
        //Calculamos la cantidad de USDD que tienen en debt
        /*uint256 UsddDebt = s_USDDMinted[user];
        if (debtToCover >= UsddDebt) {
            revert DSCEngine__AmountToLiquidateExeceedTheBalanceOfClient();
        }*/
        //!NEcesitamos saber cual es el valor de los stablecoins debt en tokens de collateral (ETH o BTC).
        //!Es necesesario para saber cuanto collateral extraer del liquidado y darselo al liquidador
        //!Le daremos un BONUS de 10% por ejecutar la liquidacion y proteger el protocolo
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
        //Ejecutamos el envio de tokens y burn del liquidador
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
    /*
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     */
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

    //Internal or Private Fns//

    /// @notice This is a low-level prviate call with no checks in the HealthFactor. Always check the healthfactor to call this Fn
    function _burnUSDD(
        uint256 amountToBurn,
        address onBehalfOf,
        address usddFrom
    ) private {
        //CEI
        //Checks

        //Effects
        //Quitamos el debt/Usdd apuntados en su mapping de stablecoins minteadas. es decir, como cogio un loan,
        //se apuntaron en su mapping la cantidad en USD/ numero de tokens usdd minteados.
        //Como le estan liquidando, otro usuario paga su deuda y se le suprime a cliente.
        s_USDDMinted[onBehalfOf] -= amountToBurn;
        emit UsddBurned(usddFrom, amountToBurn);

        //Interactions
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
        //!necesitamos obtener todo el value del collateral y todo el USDD que tiene el user
        (
            uint256 totalMintedUSDD,
            uint256 collateralValueInUSD
        ) = _getAccountInformation(user);
        console.log("Esto es totalMintedUSDD", totalMintedUSDD);
        console.log("Esto es collateralValueInUSD", collateralValueInUSD);
        //!Chequeamos si el usuario tiene MintedUsdd, si no retornamos el MIN_HEALTH_FACTOR
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
        // uint256 healthFactor = ((collateralAdjustedForThreshold * PRECISION) /
        //     totalMintedUSDD); //! Error cometido grave yo mismo. Añadí PRecision y eso rompio todo
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
                (uint256(answerETH) * ADDITIONAL_FEED_PRECISION); //!We have to add PRecison extra because of how SOlidity works
        }

        if (tokenAddress == s_wBTC) {
            (, int256 answerBTC, , , ) = s_priceFeedBTC
                .checkIfOnLatestRoundData();
            return
                (usdAmountOfDebt * PRECISION * PRECISION) /
                (uint256(answerBTC) * ADDITIONAL_FEED_PRECISION); //!We have to add PRecison extra because of how SOlidity works
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
