// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    function setUp() public {}

    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}
