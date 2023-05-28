pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingContract is ReentrancyGuard {
    IERC721 public nftToken;
    IERC20 public pepegToken;
    
    struct StakeInfo {
        uint256 stakeTimestamp;
        bool rewardClaimed;
    }
    
    // Mapping from token ID to stake info
    mapping(uint256 => StakeInfo) public stakeInfo;

    uint256 public constant STAKE_PERIOD = 7 days;
    uint256 public constant REWARD_AMOUNT = 10000 * (10 ** 18); // Assuming 18 decimal places

    constructor(address _nftToken, address _pepegToken) {
        nftToken = IERC721(_nftToken);
        pepegToken = IERC20(_pepegToken);
    }

    function stakeNFT(uint256 tokenId) external {
        // Transfer the NFT to this contract
        nftToken.transferFrom(msg.sender, address(this), tokenId);

        // Record the stake
        stakeInfo[tokenId] = StakeInfo(block.timestamp, false);
    }

    function withdrawNFT(uint256 tokenId) external nonReentrant {
        require(stakeInfo[tokenId].stakeTimestamp + STAKE_PERIOD <= block.timestamp, "Staking period not yet complete");
        require(!stakeInfo[tokenId].rewardClaimed, "Reward already claimed");

        // Mark the reward as claimed
        stakeInfo[tokenId].rewardClaimed = true;

        // Transfer the NFT back to the owner
        nftToken.transferFrom(address(this), msg.sender, tokenId);

        // Mint the reward tokens to the owner
        // This assumes the staking contract has the ability to mint PEPEG tokens.
        // If it doesn't, the PEPEG tokens will need to be transferred from another source.
        pepegToken.transfer(msg.sender, REWARD_AMOUNT);
    }
}
