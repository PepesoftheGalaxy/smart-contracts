// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PepeStaking is ReentrancyGuard {
    using SafeMath for uint256;

    struct StakeInfo {
        uint256 stakedTime;
        bool staked;
    }

    IERC721 public pepeNFT;
    IERC20 public pepeToken;

    uint256 public minStakingTime = 7 days;
    uint256 public rewardAmount = 10000 * (10 ** 18);  // 10000 tokens with 18 decimals
    uint256 public totalRewards;

    mapping(address => StakeInfo) public stakingInfo;
    mapping(address => uint256) public userRewards;

    event Stake(address indexed user, uint256 time);
    event Withdraw(address indexed user, uint256 time, uint256 reward);
    event RewardIncreased(address indexed user, uint256 reward);
    event RewardDecreased(address indexed user, uint256 reward);

    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IERC721(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

    function stakeNFT(uint256 tokenId) external {
        require(pepeNFT.ownerOf(tokenId) == msg.sender, "Not owner of this NFT");
        require(!stakingInfo[msg.sender].staked, "Already staking an NFT");

        // Transfer the NFT to this contract
        pepeNFT.transferFrom(msg.sender, address(this), tokenId);

        // Update staking info
        stakingInfo[msg.sender] = StakeInfo(block.timestamp, true);

        emit Stake(msg.sender, block.timestamp);
    }

    function withdrawNFT(uint256 tokenId) external nonReentrant {
        require(pepeNFT.ownerOf(tokenId) == address(this), "Contract is not owner of this NFT");
        require(stakingInfo[msg.sender].staked, "Not staking an NFT");
        require(block.timestamp >= stakingInfo[msg.sender].stakedTime.add(minStakingTime), "Minimum staking time not reached");

        // Transfer the NFT back to the user
        pepeNFT.transferFrom(address(this), msg.sender, tokenId);

        // Update staking info
        stakingInfo[msg.sender].staked = false;

        // Transfer the reward
        pepeToken.transfer(msg.sender, userRewards[msg.sender]);

        emit Withdraw(msg.sender, block.timestamp, userRewards[msg.sender]);

        // Decrease the total rewards and user rewards
        totalRewards = totalRewards.sub(userRewards[msg.sender]);
        userRewards[msg.sender] = 0;

        emit RewardDecreased(msg.sender, userRewards[msg.sender]);
    }

    function getRemainingStakeTime(address user) public view returns (uint256) {
        if(block.timestamp >= stakingInfo[user].stakedTime.add(minStakingTime)) {
            return 0;
        } else {
            return stakingInfo[user].stakedTime.add(minStakingTime).sub(block.timestamp);
        }
    }

    function increaseRewards(address user) external {
        require(userRewards[user] < rewardAmount, "Already received full rewards");

        userRewards[user] = rewardAmount;
       quote("Here's the updated contract with", "userRewards[user] = rewardAmount;")
