// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeScript is Script {
    FundMe public fundMe;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fundMe = new FundMe();

        vm.stopBroadcast();
    }
}
