// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfund {
    struct Campaign {
        address creator;
        uint256 target;
        uint256 pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    event Launch(uint256 id, address indexed creator, uint256 target, uint32 startAt, uint32 endAt);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 indexed id, address indexed caller, uint256 amount);

    function launch(uint256 _target, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= uint32(block.timestamp), "Start time must be in the future");
        require(_endAt > _startAt, "End time must be after start time");
        require(_endAt <= block.timestamp + 90 days, "Campaign cannot exceed 90 days");

        campaignCount += 1;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            target: _target,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(campaignCount, msg.sender, _target, _startAt, _endAt);
    }

    function pledge(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not started");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");

        campaign.pledged += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;

        emit Pledge(_id, msg.sender, msg.value);
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "Only the creator can claim");
        require(block.timestamp > campaign.endAt, "Campaign has not ended yet");
        require(campaign.pledged >= campaign.target, "Funding target was not reached");
        require(!campaign.claimed, "Funds have already been claimed");

        campaign.claimed = true;
        uint256 amount = campaign.pledged;
        
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH to creator");

        emit Claim(_id);
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign has not ended yet");
        require(campaign.pledged < campaign.target, "Funding target was reached");

        uint256 amount = pledgedAmount[_id][msg.sender];
        require(amount > 0, "No funds pledged to refund");

        // Set to zero BEFORE sending ETH to prevent reentrancy attacks
        pledgedAmount[_id][msg.sender] = 0;
        
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH refund");

        emit Refund(_id, msg.sender, amount);
    }
}
