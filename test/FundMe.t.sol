// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() public {
        fundMe = new FundMeScript().run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgRender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testAggregatorVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }
}
