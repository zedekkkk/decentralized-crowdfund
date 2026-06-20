// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract CrowdfundTest is Test {
    Crowdfund public crowdfund;
    address public creator = address(1);
    address public donor = address(2);

    uint256 public targetAmount = 10 ether;
    uint32 public startAt;
    uint32 public endAt;

    function setUp() public {
        crowdfund = new Crowdfund();
        
        // Set realistic block timestamps for testing
        startAt = uint32(block.timestamp + 1 days);
        endAt = uint32(block.timestamp + 30 days);
        
        // Give our test account some play money (ETH)
        vm.deal(donor, 100 ether);
    }

    function testLaunchCampaign() public {
        vm.prank(creator);
        crowdfund.launch(targetAmount, startAt, endAt);

        (address contractCreator, uint256 target, uint256 pledged, uint32 start, uint32 end, bool claimed) = crowdfund.campaigns(1);

        assertEq(contractCreator, creator);
        assertEq(target, targetAmount);
        assertEq(pledged, 0);
        assertEq(start, startAt);
        assertEq(end, endAt);
        assertEq(claimed, false);
    }

    function testPledgeFunds() public {
        // 1. Launch the campaign first
        vm.prank(creator);
        crowdfund.launch(targetAmount, startAt, endAt);

        // 2. Fast-forward time so the campaign becomes active
        vm.warp(startAt + 1 hours);

        // 3. Simulate donor pledging 5 ETH
        vm.prank(donor);
        crowdfund.pledge{value: 5 ether}(1);

        (, , uint256 pledged, , , ) = crowdfund.campaigns(1);
        assertEq(pledged, 5 ether);
        assertEq(crowdfund.pledgedAmount(1, donor), 5 ether);
    }

    function testRefundOnFailure() public {
        vm.prank(creator);
        crowdfund.launch(targetAmount, startAt, endAt);

        vm.warp(startAt + 1 hours);

        vm.prank(donor);
        crowdfund.pledge{value: 4 ether}(1); // Goal is 10, only pledged 4

        // Fast forward past the end date (campaign fails)
        vm.warp(endAt + 1 hours);

        uint256 balanceBefore = donor.balance;

        // Claim refund
        vm.prank(donor);
        crowdfund.refund(1);

        uint256 balanceAfter = donor.balance;
        assertEq(balanceAfter - balanceBefore, 4 ether);
    }
}
