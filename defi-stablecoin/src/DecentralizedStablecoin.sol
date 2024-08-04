// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable, ERC20} from "@openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

/// @title DecentralizedStablecoin
/// @author Alejandro G.
/// @notice Collateral: Exogenous(ETH & BTC)
/// @notice Minting: Algorithmic
/// @notice Relative Stability: Pegged to USD dollar
///
///
/// @dev This is the contract to be governed by the DSCEngine logic container. This contract is just a
/// @dev ERC20 implementation of our stablecoin.

contract DecentralizedStablecoin is ERC20Burnable, Ownable {
    //ERRORS//
    error DecentralizedStablecoin__MustBeMoreThanZero();
    error DecentralizedStablecoin__NotEnoughtBalance();
    error DecentralizedStablecoin__NotZeroAddress();

    constructor(
        address initialOwner
    ) ERC20("USDDecentralized", "USDD") Ownable(initialOwner) {}

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
