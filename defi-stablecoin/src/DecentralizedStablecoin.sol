// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable, ERC20} from "@openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

/// @title DecentralizedStablecoin
/// @author Alejandro G.
/// @notice Collateral: Exogenous (ETH & BTC)
/// @notice Minting: Algorithmic
/// @notice Relative Stability: Pegged to USD dollar
/// @dev This contract is governed by the DSCEngine logic container.
/// @dev It implements an ERC20 token representing a stablecoin.
contract DecentralizedStablecoin is ERC20Burnable, Ownable {
    //ERRORS//
    /// @dev Thrown when the input value is zero.
    error DecentralizedStablecoin__MustBeMoreThanZero();

    /// @dev Thrown when trying to burn an amount greater than the available balance.
    error DecentralizedStablecoin__NotEnoughtBalance();

    /// @dev Thrown when trying to interact with the zero address.
    error DecentralizedStablecoin__NotZeroAddress();

    /// @notice Constructor to initialize the DecentralizedStablecoin contract.
    /// @param initialOwner The address to set as the initial owner of the contract.
    constructor(
        address initialOwner
    ) ERC20("USDDecentralized", "USDD") Ownable(initialOwner) {}

    /// @notice Burns a specified amount of tokens from the caller's balance.
    /// @dev Only the owner can call this function.
    /// @param _amount The amount of tokens to burn.
    /// @custom:reverts DecentralizedStablecoin__MustBeMoreThanZero If the balance is zero.
    /// @custom:reverts DecentralizedStablecoin__NotEnoughtBalance If the amount exceeds the balance.
    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (balance <= 0) {
            revert DecentralizedStablecoin__MustBeMoreThanZero();
        }
        if (_amount > balance) {
            revert DecentralizedStablecoin__NotEnoughtBalance();
        }
        super.burn(_amount);
    }

    /// @notice Mints a specified amount of tokens to a given address.
    /// @dev Only the owner can call this function.
    /// @param _to The address to receive the minted tokens.
    /// @param _amount The amount of tokens to mint.
    /// @return A boolean value indicating if the minting was successful.
    /// @custom:reverts DecentralizedStablecoin__NotZeroAddress If the `_to` address is zero.
    /// @custom:reverts DecentralizedStablecoin__MustBeMoreThanZero If the `_amount` is zero or less.
    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStablecoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStablecoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
