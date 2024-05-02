// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {FundMeScript} from "../../script/FundMe.s.sol";

import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegration is Test {

     FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        FundMeScript deployFundMe = new FundMeScript();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testUserCanFundInteraction() external{

        // vm.deal(USER, STARTING_BALANCE);
        // vm.startPrank(USER);
        // fundMe.cheaperWithdraw();
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        // vm.stopPrank();

        // address funder = fundMe.getFunder(0);
        assertEq(address(fundMe).balance, 0);

    }
}
