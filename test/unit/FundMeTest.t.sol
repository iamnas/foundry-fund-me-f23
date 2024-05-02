// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {FundMeScript} from "../../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        FundMeScript deployFundMe = new FundMeScript();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumDollerIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        

        address getFunder = fundMe.getFunder(0);
        uint256 amountFunded = fundMe.getAddressToAmountFunded(getFunder);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded{
      
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        // vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;  

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert   

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {

        // Arrange

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(;startingFunderIndex<=numberOfFunders;startingFunderIndex++){
            hoax(address(startingFunderIndex),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        } 

        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;  

        // Act
        // vm.prank(fundMe.getOwner());
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert   

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFundersCheaper() public funded {

        // Arrange

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(;startingFunderIndex<=numberOfFunders;startingFunderIndex++){
            hoax(address(startingFunderIndex),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        } 

        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;  

        // Act
        // vm.prank(fundMe.getOwner());
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert   

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);

    }



}
