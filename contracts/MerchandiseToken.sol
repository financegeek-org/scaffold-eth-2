// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerchandiseTokenFaucet} from "./MerchandiseTokenFaucet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerchandiseToken is Ownable {
    error ContractNotApprovedForSpend();
    error InsufficientUSDCBalance();
    error TransactionFailed();

    address immutable i_ADVERTISER;
    address immutable i_FAUCET;
    address immutable i_STABLECOIN;
    //0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913

    constructor(address _advertiser, address _stableCoinContract) Ownable(msg.sender) {
        i_ADVERTISER = _advertiser;
        i_FAUCET = msg.sender;
        i_STABLECOIN = _stableCoinContract;
    }

    function buyToken(uint256 _numberOfTokens) external {
        uint256 totalPrice = _numberOfTokens * MerchandiseTokenFaucet(i_FAUCET).getPriceOfItem();

        if (
            IERC20(i_STABLECOIN).allowance(msg.sender, address(this)) <
            totalPrice
        ) {
            revert ContractNotApprovedForSpend();
        }

        if(IERC20(i_STABLECOIN).balanceOf(msg.sender) < totalPrice){
            revert InsufficientUSDCBalance();
        }

        uint256 advertiserCut = MerchandiseTokenFaucet(i_FAUCET).getAdvertiserCommision() * _numberOfTokens;

        bool advertiserSuccess = IERC20(i_STABLECOIN).transferFrom(msg.sender, i_ADVERTISER, advertiserCut);
        bool sellerSuccess = IERC20(i_STABLECOIN).transferFrom(msg.sender, MerchandiseTokenFaucet(i_FAUCET).owner(), (totalPrice - advertiserCut));

        if(!advertiserSuccess || !sellerSuccess){
            revert TransactionFailed();
        }

        MerchandiseTokenFaucet(i_FAUCET).transferTokenOnSell(_numberOfTokens);
    }

    function redeemToken(uint256 _numberOfTokens) external {
        MerchandiseTokenFaucet(i_FAUCET).redeemToken(_numberOfTokens);
    }
}
