pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PepeStaking is ReentrancyGuard {
    struct StakeInfo {
        uint256 stakeTimestamp;
        bool rewardClaimed;
    }

    IERC721 public nftToken;
    IERC20 public pepegToken;

    uint256 public constant STAKE_PERIOD = 7 days;
    uint256 public constant REWARD_AMOUNT = 10000 * 10**18; // Assuming PEPEG has 18 decimals

    mapping(uint256 => StakeInfo) public stakeInfo;

    event Staked(uint256 tokenId);
    event Withdrawn(uint256 tokenId);

    constructor(IERC721 _nftToken, IERC20 _pepegToken) {
        nftToken = _nftToken;
        pepegToken = _pepegToken;
    }

    function stakeNFT(uint256 tokenId) external nonReentrant {
        nftToken.transferFrom(msg.sender, address(this), tokenId);
        stakeInfo[tokenId] = StakeInfo(block.timestamp, false);

        emit Staked(tokenId);
    }

    function withdrawNFT(uint256 tokenId) external nonReentrant {
        require(stakeInfo[tokenId].stakeTimestamp + STAKE_PERIOD <= block.timestamp, "Staking period not yet complete");
        require(!stakeInfo[tokenId].rewardClaimed, "Reward already claimed");

        stakeInfo[tokenId].rewardClaimed = true;

        nftToken.transferFrom(address(this), msg.sender, tokenId);

        require(pepegToken.balanceOf(address(this)) >= REWARD_AMOUNT, "Insufficient PEPEG balance in staking contract");
        pepegToken.transfer(msg.sender, REWARD_AMOUNT);

        emit Withdrawn(tokenId);
    }
}
