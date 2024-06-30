// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MerchandiseTokenFaucet} from "../src/MerchandiseTokenFaucet.sol";

contract DeployFaucet is Script {
    uint256 priceOfItem = 10;
    uint256 advertiserComission = 2;

    function run() public {

        vm.startBroadcast();
        MerchandiseTokenFaucet temp = new MerchandiseTokenFaucet(priceOfItem, advertiserComission);
        temp.createNewAdvertiserContract(0x34E56783c97E0BaF0ea52B73Ac32D7f5AC815A4C, 0x036CbD53842c5426634e7929541eC2318f3dCF7e);
        vm.stopBroadcast();
    }
}