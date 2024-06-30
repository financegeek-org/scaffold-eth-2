// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20 {

    constructor() ERC20("USDC", "USDC") {
        _mint(0x6Bd07000C5F746af69BEe7f151eb30285a6678B2, 10000);
    }
}