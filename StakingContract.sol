pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract StakingContract is ERC721Holder {
    IERC721 public nftAddress;
    address public PEPEG_TOKEN_ADDRESS;
    uint256 public constant STAKING_PERIOD = 7 days;

    struct Stake {
        uint256 tokenId;
        uint256 timeStaked;
    }

    mapping (address => Stake) private _stakes;
    mapping (address => uint256) private _totalRewards;

    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 tokenId, uint256 reward, uint256 timestamp);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _nftAddress, address _pepegTokenAddress) {
        nftAddress = IERC721(_nftAddress);
        PEPEG_TOKEN_ADDRESS = _pepegTokenAddress;
    }

    function stakeNFT(uint256 _tokenId) external {
        nftAddress.safeTransferFrom(msg.sender, address(this), _tokenId);
        _stakes[msg.sender] = Stake(_tokenId, block.timestamp);
        emit Staked(msg.sender, _tokenId, block.timestamp);
    }

    function withdrawNFT(uint256 _tokenId) external {
        require(_stakes[msg.sender].tokenId == _tokenId, "NFT not staked");
        require(block.timestamp >= _stakes[msg.sender].timeStaked + STAKING_PERIOD, "Staking period not over");

        uint256 reward = 10000; // amount of PEPEG tokens rewarded

        // Update the user's total accumulated rewards.
        _totalRewards[msg.sender] -= reward;

        IERC20(PEPEG_TOKEN_ADDRESS).transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);

        _stakes[msg.sender].tokenId = 0;
        _stakes[msg.sender].timeStaked = 0;

        nftAddress.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Withdrawn(msg.sender, _tokenId, reward, block.timestamp);
    }

    function totalRewards(address user) external view returns (uint256) {
        return _totalRewards[user];
    }
}
