// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {DecentralizedStablecoin} from "../../src/DecentralizedStablecoin.sol";

contract DecentralizedStablecoinTest is Test {
    DecentralizedStablecoin public s_dsc;
    address public USER = makeAddr("user");

    function setUp() public {
        DecentralizedStablecoin dsc = new DecentralizedStablecoin(USER);
        s_dsc = dsc;
    }

    //CONSTRUCTOR//
    function testRightInitialized() external view {
        assertEq(s_dsc.name(), "USDDecentralized");
        assertEq(s_dsc.symbol(), "USDD");
    }

    //MINTING//
    function testmintToOnlyOwner() external {
        vm.expectRevert();
        s_dsc.mint(USER, 10);
    }
    function testMintRevertToAddress0() external {
        vm.prank(USER);
        vm.expectRevert();
        s_dsc.mint(address(0), 10);
    }
    function testMintRevertIfAmount0() external {
        vm.prank(USER);
        vm.expectRevert();
        s_dsc.mint(USER, 0);
    }

    function testCorrectMinting() external {
        vm.prank(USER);
        s_dsc.mint(USER, 10);

        uint256 balance = s_dsc.balanceOf(USER);
        console.log(balance);
        assert(balance == 10);
    }

    //BURNING//

    modifier minting() {
        vm.prank(USER);
        s_dsc.mint(USER, 10);

        _;
    }

    function testBurnBalanceMoreThanZero() external {
        vm.prank(USER);
        vm.expectRevert();
        s_dsc.burn(0);
    }
    function testBurnAmountMoreThanBalance() external minting {
        vm.prank(USER);
        vm.expectRevert();
        s_dsc.burn(11);
    }

    function testCorrectBurning() external minting {
        vm.prank(USER);
        s_dsc.burn(9);

        assertEq(s_dsc.balanceOf(USER), 1);
    }
}
