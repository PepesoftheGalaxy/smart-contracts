// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PepesOfTheGalaxyToken.sol";

contract PepesOfTheGalaxyLaunchPool {
    mapping(address => uint256) public stakes;
    uint256 public totalStaked;
    PepesOfTheGalaxyToken public token;

    constructor(address tokenAddress) {
        token = PepesOfTheGalaxyToken(tokenAddress);
    }

    function stake() public payable {
        // Update the staker's stake and the total staked amount
        stakes[msg.sender] += msg.value;
        totalStaked += msg.value;
    }

    function claim() public {
        // Calculate the staker's share of the PEPEOG tokens in the pool
        uint256 reward = token.balanceOf(address(this)) * stakes[msg.sender] / totalStaked;

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = 0;
        totalStaked -= stakes[msg.sender];

        // Transfer the reward to the staker
        token.transfer(msg.sender, reward);
    }
}