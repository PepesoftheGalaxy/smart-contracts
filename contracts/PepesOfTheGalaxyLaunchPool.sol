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
    uint256 public totalStaked;
    PepesOfTheGalaxyToken public token;
    uint256 public constant STAKING_PERIOD = 7 days;
    uint256 public stakingStart;
    uint256 public stakingEnd;
    uint256 public constant FEE_PERCENT = 25; // 0.25%
    address payable public feeRecipient;

    constructor(address tokenAddress, uint256 _stakingStart, address payable _feeRecipient) {
        token = PepesOfTheGalaxyToken(tokenAddress);
        stakingStart = _stakingStart;
        stakingEnd = stakingStart.add(STAKING_PERIOD);
        feeRecipient = _feeRecipient;
    }

    function stake() public payable whenNotPaused nonReentrant {
        require(block.timestamp >= stakingStart, "Staking period not started");
        require(block.timestamp < stakingEnd, "Staking period ended");
        require(msg.value > 0, "Must stake a positive amount");

        uint256 fee = msg.value.mul(FEE_PERCENT).div(10000); // Calculate the fee
        uint256 amountAfterFee = msg.value.sub(fee); // Subtract the fee from the staked amount

        // Transfer the fee to the fee recipient
        feeRecipient.transfer(fee);

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = stakes[msg.sender].add(amountAfterFee);
        totalStaked = totalStaked.add(amountAfterFee);
    }

    function claimAndWithdraw() public whenNotPaused nonReentrant {
        require(block.timestamp >= stakingEnd, "Staking period not yet over");

        uint256 userStake = stakes[msg.sender];
        require(userStake > 0, "No stake to claim");

        // Calculate the staker's share of the PEPEOG
        uint256 reward = token.balanceOf(address(this)).mul(userStake).div(totalStaked);

        // Update the staker's stake and the total staked amount
        stakes[msg.sender] = 0;
        totalStaked = totalStaked.sub(userStake);

        // Transfer the reward to the staker
        token.transfer(msg.sender, reward);

        // Transfer the staked BNB back to the staker
        payable(msg.sender).transfer(userStake);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}