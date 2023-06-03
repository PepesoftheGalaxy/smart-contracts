// SPDX-License-Identifier: MIT
// This declares the license this source code is released under
pragma solidity ^0.8.0;
// Solidity version this smart contract was written in

// Importing ERC721 (for NFTs) and ERC20 (for fungible tokens) interface from openzeppelin contracts
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Importing reentrancy guard from openzeppelin to prevent reentrant attacks
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Importing SafeMath from openzeppelin to perform safe arithmetic operations
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Declaring the smart contract
contract PepesOfTheGalaxyNFTStaking is ReentrancyGuard {
    // SafeMath library is used to handle uint256 types
    using SafeMath for uint256;

    // Struct for storing stake info of a user
    struct StakeInfo {
        uint256 stakedTime;  // Time when the NFT was staked
        bool staked;  // If the user has staked an NFT or not
    }

    // Defining interfaces for interacting with the NFT and Token contracts
    IERC721 public pepeNFT;
    IERC20 public pepeToken;

    // Minimum time required to stake the NFT to earn rewards
    uint256 public minStakingTime = 7 days;

    // Amount of reward each stakeholder gets
    uint256 public rewardAmount = 10000 * (10 ** 18);

    // Total rewards distributed
    uint256 public totalRewards;

    // Mapping to keep track of user's staking info and rewards
    mapping(address => StakeInfo) public stakingInfo;
    mapping(address => uint256) public userRewards;

    // Events to emit
    event Stake(address indexed user, uint256 time);
    event Withdraw(address indexed user, uint256 time, uint256 reward);
    event RewardIncreased(address indexed user, uint256 reward);
    event RewardDecreased(address indexed user, uint256 reward);

    // Constructor to initialize the NFT and Token contracts
    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IERC721(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

    // Function to stake NFT
    function stakeNFT(uint256 tokenId) external {
        // Check if the sender is the owner of the NFT and if he is not already staking
        require(pepeNFT.ownerOf(tokenId) == msg.sender, "Not owner of this NFT");
        require(!stakingInfo[msg.sender].staked, "Already staking an NFT");

        // Transfer the NFT to this contract
        pepeNFT.transferFrom(msg.sender, address(this), tokenId);

        // Update staking info
        stakingInfo[msg.sender] = StakeInfo(block.timestamp, true);

        // Emit the Stake event
        emit Stake(msg.sender, block.timestamp);
    }

    // Function to withdraw NFT
    function withdrawNFT(uint256 tokenId) external nonReentrant {
        // Check if the contract owns the NFT and if the sender is staking
        require(pepeNFT.ownerOf(tokenId) == address(this), "Contract is not owner of this NFT");
        require(stakingInfo[msg.sender].staked, "Not staking an NFT");
        require(block.timestamp >= stakingInfo[msg.sender].stakedTime.add(minStakingTime), "Minimum staking time not reached");

        // Transfer the NFT back to the user
        pepeNFT.transferFrom(address(this), msg.sender, tokenId);

        // Update staking info
        stakingInfo[msg.sender].staked = false;

        // Transfer the reward
        pepeToken.transfer(msg.sender, userRewards[msg.sender]);

        // Emit the Withdraw event
        emit Withdraw(msg.sender, block.timestamp, userRewards[msg.sender]);

        // Decrease the total rewards and user rewards
        totalRewards = totalRewards.sub(userRewards[msg.sender]);
        userRewards[msg.sender] = 0;

        // Emit the RewardDecreased event
        emit RewardDecreased(msg.sender, userRewards[msg.sender]);
    }

    // Function to get remaining stake time
    function getRemainingStakeTime(address user) public view returns (uint256) {
        if(block.timestamp >= stakingInfo[user].stakedTime.add(minStakingTime)) {
            return 0;
        } else {
            return stakingInfo[user].stakedTime.add(minStakingTime).sub(block.timestamp);
        }
    }

    // Function to increase rewards for a user
    function increaseRewards(address user) external {
        // Check if the user already received full rewards
        require(userRewards[user] < rewardAmount, "Already received full rewards");

        // Increase the user's reward
        userRewards[user] = rewardAmount;
    }
}
