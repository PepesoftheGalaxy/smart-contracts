// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PepesOfTheGalaxyNFTStaking is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    struct StakeInfo {
        uint256 stakedTime;
        bool staked;
    }

    IERC721 public pepeNFT;
    IERC20 public pepeToken;

    // Minimum time required to stake the NFT to earn rewards (1 hour).
    uint256 public minStakingTime = 1 hours;

    // Amount of reward each stakeholder gets.
    uint256 public rewardAmount = 10000 * (10 ** 18);

    mapping(address => StakeInfo) public stakingInfo;
    mapping(address => uint256) public userRewards;

    event Stake(address indexed user, uint256 time);
    event Withdraw(address indexed user, uint256 time, uint256 reward);

    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IERC721(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

    function stakeNFT(uint256 tokenId) external {
        require(pepeNFT.ownerOf(tokenId) == msg.sender, "Not owner of this NFT");
        require(!stakingInfo[msg.sender].staked, "Already staking an NFT");

        pepeNFT.transferFrom(msg.sender, address(this), tokenId);

        stakingInfo[msg.sender] = StakeInfo(block.timestamp, true);

        emit Stake(msg.sender, block.timestamp);
    }

    function withdrawNFT(uint256 tokenId) external nonReentrant {
        require(pepeNFT.ownerOf(tokenId) == address(this), "Contract is not owner of this NFT");
        require(stakingInfo[msg.sender].staked, "Not staking an NFT");
        require(block.timestamp >= stakingInfo[msg.sender].stakedTime.add(minStakingTime), "Minimum staking time not reached");

        pepeNFT.transferFrom(address(this), msg.sender, tokenId);

        stakingInfo[msg.sender].staked = false;

        // Transfer the reward automatically.
        pepeToken.transfer(msg.sender, rewardAmount);

        emit Withdraw(msg.sender, block.timestamp, rewardAmount);
    }

        function setMinStakingTime(uint256 newMinStakingTime) external onlyOwner {
        minStakingTime = newMinStakingTime;
    }

    function getRemainingStakeTime(address user) public view returns (uint256) {
        if(block.timestamp >= stakingInfo[user].stakedTime.add(minStakingTime)) {
            return 0;
        } else {
            return stakingInfo[user].stakedTime.add(minStakingTime).sub(block.timestamp);
        }
    }
}
