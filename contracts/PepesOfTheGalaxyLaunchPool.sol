// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PepesOfTheGalaxyToken.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PepesOfTheGalaxyLaunchPool is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTime;
    uint256 public totalStaked;
    PepesOfTheGalaxyToken public token;
    uint256 public constant STAKING_PERIOD = 7 days;

    constructor(address tokenAddress) {
        token = PepesOfTheGalaxyToken(tokenAddress);
    }

    function stake() public payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Must stake a positive amount");

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = stakes[msg.sender].add(msg.value);
        totalStaked = totalStaked.add(msg.value);

        // Update the staker's stake time
        stakeTime[msg.sender] = block.timestamp;
    }

    function claim() public whenNotPaused nonReentrant {
        require(block.timestamp >= stakeTime[msg.sender] + STAKING_PERIOD, "Staking period not yet over");

        uint256 userStake = stakes[msg.sender];
        require(userStake > 0, "No stake to claim");

        // Calculate the staker's share of the PEP
        uint256 reward = token.balanceOf(address(this)).mul(userStake).div(totalStaked);

        // Apply a bonus based on the time staked using a bonding curve
        uint256 timeStaked = block.timestamp.sub(stakeTime[msg.sender]);
        uint256 bonus = reward.mul(timeStaked).div(STAKING_PERIOD);
        reward = reward.add(bonus);

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = 0;
        totalStaked = totalStaked.sub(userStake);

        // Transfer the reward to the staker
        token.transfer(msg.sender, reward);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}