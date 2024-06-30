// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {MerchandiseToken} from "../src/MerchandiseToken.sol";
import {MerchandiseTokenFaucet} from "../src/MerchandiseTokenFaucet.sol";
import {USDC} from "../src/utils/localUSDC.sol";

contract AdvertiserContractTest is Test {
    MerchandiseTokenFaucet faucet;
    MerchandiseToken token;
    USDC stableCoin;
    uint256 priceOfItem = 10;
    uint256 advertiserComission = 2;
    address advertiser = address(1);

    event TokenRedeemed(address redeemer, uint256 amount);
    

    function setUp() public {
        faucet = new MerchandiseTokenFaucet(priceOfItem, advertiserComission);
        stableCoin = new USDC();
        token = MerchandiseToken(faucet.createNewAdvertiserContract(advertiser, address(stableCoin)));
    }

    function testConstructor_comissionBiggerThanPrice() public {
        uint256 newCommission = priceOfItem + 1;

        vm.expectRevert(MerchandiseTokenFaucet.CommissionMustBeSmallerThanPrice.selector);
        faucet = new MerchandiseTokenFaucet(priceOfItem, newCommission);
    }

    function testBuyToken_works() public {
        stableCoin.approve(address(token), stableCoin.balanceOf(address(this)));
        uint256 numTokensToBuy = 1;

        token.buyToken(numTokensToBuy);

        assertEq(faucet.getNumberOfTokens(tx.origin), numTokensToBuy);
    }

    function testBuyToken_notApprovedForSpend() public {
        uint256 numTokensToBuy = 1;

        vm.expectRevert(MerchandiseToken.ContractNotApprovedForSpend.selector);
        token.buyToken(numTokensToBuy);
    }

    function testBuyToken_insufficientBalance() public {
        uint256 numTokensToBuy = 1;
        vm.prank(advertiser);
        stableCoin.approve(address(token), 100);

        vm.prank(advertiser);
        vm.expectRevert(MerchandiseToken.InsufficientUSDCBalance.selector);
        token.buyToken(numTokensToBuy);
    }

    function testRedeemToken_works() public {
        testBuyToken_works();

        vm.expectEmit();
        emit TokenRedeemed(tx.origin, 1);

        token.redeemToken(1);
    }

    function testRedeemToken_insufficientBalance() public {
        vm.expectRevert(MerchandiseTokenFaucet.TokenBalanceInsufficient.selector);
        token.redeemToken(1);
    }

    function testUpdatePriceOfItem_works() public {
        uint256 newPrice = 9;
        assertEq(priceOfItem, faucet.getPriceOfItem());
        faucet.updatePriceOfItem(newPrice);

        assertEq(newPrice, faucet.getPriceOfItem());
    }

    function testUpdatePriceOfItem_onlyOwner() public {
        vm.prank(advertiser);
        vm.expectRevert();
        faucet.updatePriceOfItem(0);
    }

    function testUpdateAdvertiserComission_works() public {
        uint256 newCommission = 3;
        assertEq(advertiserComission, faucet.getAdvertiserCommision());
        faucet.updateAdvertiserCommission(newCommission);

        assertEq(newCommission, faucet.getAdvertiserCommision());
    }
}