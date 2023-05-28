// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interface for the PepesOfTheGalaxyNFT contract (ERC721)
interface IPepesOfTheGalaxyNFT {
    function getPepeAttributes(uint256 _tokenId) external view returns (uint256 appearance, uint256 accessories);
    function addExperience(uint256 _tokenId, uint256 experience) external; 
}

contract PepesOfTheGalaxyBattle is Ownable {
    // Establish connection with PepesOfTheGalaxyNFT contract
    IPepesOfTheGalaxyNFT public pepeNFT;
    // Establish connection with the token contract
    IERC20 public pepeToken;

    // Structure for a battle request
    struct BattleRequest {
        uint256 pepeId;
        uint256 amount;
        address player;
    }

    // Array to keep track of battle requests
    BattleRequest[] public battleRequests;

    // Events for staking, battle outcome and transfer
    event Staked(address indexed user, uint256 pepeId, uint256 amount);
    event Battle(address indexed user1, address indexed user2, uint256 pepeId1, uint256 pepeId2, uint256 winnerId);
    event Transfer(address indexed user, uint256 amount);

    constructor(address _pepeToken, address _pepeNFT) {
        pepeToken = IERC20(_pepeToken);
        pepeNFT = IPepesOfTheGalaxyNFT(_pepeNFT);
    }

    // Stake a specific amount of tokens with a specific NFT to participate in a battle
    function stake(uint256 _pepeId, uint256 _amount) public {
        // Transfer the staked amount from user to this contract
        require(pepeToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        // Add the staking request to the array
        battleRequests.push(BattleRequest(_pepeId, _amount, msg.sender));
        emit Staked(msg.sender, _pepeId, _amount);
        // Check if there are enough players for a battle, if yes, start one
        if (battleRequests.length >= 2) {
            matchPlayers();
        }
    }

    // Match two players for a battle
    function matchPlayers() public returns (uint256) {
        require(battleRequests.length > 1, "Not enough players");
        // Get the last two requests
        BattleRequest storage request1 = battleRequests[battleRequests.length - 1];
        BattleRequest storage request2 = battleRequests[battleRequests.length - 2];
        // Remove the processed requests
        battleRequests.pop();
        battleRequests.pop();

        // Start the battle and get the winner
        uint256 winnerId = battle(request1, request2);

        // Transfer the staked amounts to the winner
        if (winnerId == request1.pepeId) {
            pepeToken.transfer(request1.player, request1.amount + request2.amount);
            emit Transfer(request1.player, request1.amount + request2.amount);
        } else {
            pepeToken.transfer(request2.player, request1.amount + request2.amount);
            emit Transfer(request2.player, request1.amount + request2.amount);
        }

        return winnerId;
    }

    // Function for performing the battle
    function battle(BattleRequest memory request1, BattleRequest memory request2) internal returns (uint256) {
        // Get the attributes of the two pepes
        (uint256 appearance1, uint256 accessories1) = pepeNFT.getPepeAttributes(request1.pepeId);
        (uint256 appearance2, uint256 accessories2) = pepeNFT.getPepeAttributes(request2.pepeId);

        // Calculate scores
        uint256 score1 = appearance1 + accessories1;
        uint256 score2 = appearance2 + accessories2;

        // Calculate luck factor
        uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, request1.player, request1.pepeId, request2.pepeId)));
        uint256 luckFactor = randNonce % 11;
        score1 += luckFactor;
        score2 += 10 - luckFactor;

        uint256 winnerId;
        uint256 experience1 = 0;
        uint256 experience2 = 0;

        // Decide the winner and experience points
        if (score1 > score2) {
            winnerId = request1.pepeId;
            experience1 += 10;
            experience2 += 5;
        } else {
            winnerId = request2.pepeId;
            experience2 += 10;
            experience1 += 5;
        }

        // Update experience of both NFTs
        pepeNFT.addExperience(request1.pepeId, experience1);
        pepeNFT.addExperience(request2.pepeId, experience2);

        emit Battle(request1.player, request2.player, request1.pepeId, request2.pepeId, winnerId);
        return winnerId;
    }
}
