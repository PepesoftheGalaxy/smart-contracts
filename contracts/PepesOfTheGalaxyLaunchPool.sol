// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PepesOfTheGalaxyToken.sol";

contract PepesOfTheGalaxyLaunchPool {
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTime;
    uint256 public totalStaked;
    PepesOfTheGalaxyToken public token;
    uint256 public constant STAKING_PERIOD = 7 days;

    constructor(address tokenAddress) {
        token = PepesOfTheGalaxyToken(tokenAddress);
    }

    function stake() public payable {
        // Update the staker's stake and the total staked amount
        stakes[msg.sender] += msg.value;
        totalStaked += msg.value;

        // Update the staker's stake time
        stakeTime[msg.sender] = block.timestamp;
    }

    function claim() public {
        require(block.timestamp >= stakeTime[msg.sender] + STAKING_PERIOD, "Staking period not yet over");

        // Calculate the staker's share of the PEPEOG tokens in the pool
        uint256 reward = token.balanceOf(address(this)) * stakes[msg.sender] / totalStaked;

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = 0;
        totalStaked -= stakes[msg.sender];

        // Transfer the reward to the staker
        token.transfer(msg.sender, reward);
    }
}