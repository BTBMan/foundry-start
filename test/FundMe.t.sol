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

    function testFundFailsWithoutEnoughtETH() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(user);

        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getFunders(0), user);
        assertEq(fundMe.getAddressToAmountFunded(user), SEND_VALUE);
    }
}
