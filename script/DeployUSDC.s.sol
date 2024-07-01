// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {USDC} from "../src/utils/localUSDC.sol";

contract DeployUSDC is Script {
    function run() public {
        vm.startBroadcast();
        USDC temp = new USDC();
        vm.stopBroadcast();
    }
}