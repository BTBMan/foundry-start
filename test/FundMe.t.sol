// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(user);

        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() public {
        fundMe = new FundMeScript().run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgRender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testAggregatorVersion() public view {
        assertGe(fundMe.getVersion(), 0);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        assertEq(fundMe.getAddressToAmountFunded(user), SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunders(0), user);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();

        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.txGasPrice(GAS_PRICE); // set gasprice by using cheatcode
        uint256 gasStart = gasleft();

        vm.prank(fundMe.i_owner());

        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunder() public funded {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax = deal + prank

            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner());

        fundMe.withdraw();

        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testCheaperWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.i_owner());

        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
