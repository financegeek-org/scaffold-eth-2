// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerchandiseToken} from "./MerchandiseToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MerchandiseTokenFaucet is Ownable {
    error OnlyTokenContract();
    error TokenBalanceInsufficient();
    error CommissionMustBeSmallerThanPrice();

    MerchandiseToken[] listOfTokenContracts;
    mapping(address => bool) isTokenContract;
    uint256 s_priceOfItem;
    uint256 s_advertiserCommission;
    mapping(address => uint256) tokensPerAddress;
    mapping(address => uint256) numTokensSold;

    event TokenRedeemed(address redeemer, uint256 amount);

    modifier onlyTokenContract() {
        if(!isTokenContract[msg.sender]){
            revert OnlyTokenContract();
        }
        _;
    }

    constructor(
        uint256 _priceOfItem,
        uint256 _advertiserCommission
    ) Ownable(msg.sender) {
        if(_priceOfItem < _advertiserCommission){
            revert CommissionMustBeSmallerThanPrice();
        }

        s_priceOfItem = _priceOfItem;
        s_advertiserCommission = _advertiserCommission;
        isTokenContract[address(this)] = true;
    }

    function createNewAdvertiserContract(address _advertiser, address _stableCoinAddress) external onlyOwner returns(address){
        MerchandiseToken temp = new MerchandiseToken(_advertiser, _stableCoinAddress);
        listOfTokenContracts.push(temp);
        isTokenContract[address(temp)] = true;
        return address(temp);
    }

    function transferTokenOnSell(uint256 _numberOfTokens) public onlyTokenContract {
        tokensPerAddress[tx.origin] += _numberOfTokens;
        numTokensSold[msg.sender] += _numberOfTokens;
    }

    function redeemToken(uint256 _numberOfTokens) external {
        if(tokensPerAddress[tx.origin] < _numberOfTokens){
            revert TokenBalanceInsufficient();
        }

        tokensPerAddress[tx.origin] -= _numberOfTokens;

        emit TokenRedeemed(tx.origin, _numberOfTokens);
    }

    function updatePriceOfItem(uint256 _newPrice) external onlyOwner {
        s_priceOfItem = _newPrice;
    }

    function updateAdvertiserCommission(uint256 _newCommission) external onlyOwner {
        if(_newCommission > s_priceOfItem){
            revert CommissionMustBeSmallerThanPrice();
        }
        s_advertiserCommission = _newCommission;
    }

    function getNumberOfTokens(address _owner) external view returns(uint256){
        return tokensPerAddress[_owner];
    }

    function getPriceOfItem() external view returns(uint256){
        return s_priceOfItem;
    }

    function getAdvertiserCommision() external view returns(uint256){
        return s_advertiserCommission;
    }
}
