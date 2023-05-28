// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interface for the Pepes contract (ERC721)
interface IPepes {
    // A method to get the Pepe's attributes
    function getPepeAttributes(uint256 _tokenId) external view returns (uint256 appearance, uint256 accessories);
}

// Main game contract
contract PepesOfTheGalaxyBattle is Ownable {
    // Reference to the Pepes contract
    IPepes public pepes;

    // Reference to the Pepeg token contract (ERC20)
    ERC20 public pepegToken;

    // Battle request struct
    struct BattleRequest {
        uint256 pepeId;
        uint256 amount;
        address player;
    }

    // Array to store the battle requests
    BattleRequest[] public battleRequests;

    // Event emitted when a user stakes their Pepe
    event Staked(address indexed user, uint256 pepeId, uint256 amount);

    // Event emitted when a battle occurs
    event Battle(address indexed user1, address indexed user2, uint256 pepeId1, uint256 pepeId2, uint256 winnerId);

    // Event emitted when Pepeg tokens are transferred to the winner
    event Transfer(address indexed user, uint256 amount);

    // The contract constructor, requires the addresses of the Pepeg token contract and the Pepes contract
    constructor(address _pepegToken, address _pepes) {
        pepegToken = ERC20(_pepegToken);
        pepes = IPepes(_pepes);
    }

    // Function to stake Pepe and Pepeg tokens to participate in the game
    function stake(uint256 _pepeId, uint256 _amount) public {
        // Transfer Pepeg tokens from the user to this contract
        require(pepegToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        // Add the battle request
        battleRequests.push(BattleRequest(_pepeId, _amount, msg.sender));

        // Emit the Staked event
        emit Staked(msg.sender, _pepeId, _amount);

        // If there are at least two players, start a battle
        if (battleRequests.length >= 2) {
            matchPlayers();
        }
    }

    // Function to initiate a battle between two Pepes
    function matchPlayers() public returns (uint256) {
        require(battleRequests.length > 1, "Not enough players");

        // Get the battle requests of the two players
        BattleRequest storage request1 = battleRequests[battleRequests.length - 1];
        BattleRequest storage request2 = battleRequests[battleRequests.length - 2];

        // Remove the battle requests
        battleRequests.pop();
        battleRequests.pop();

        // Call the battle function
        uint256 winnerId = battle(request1, request2);

        // Transfer the staked Pepeg tokens to the winner
        if (winnerId == request1.pepeId) {
            pepegToken.transfer(request1.player, request1.amount + request2.amount);
            emit Transfer(request1.player, request1.amount + request2.amount);
        } else {
            pepegToken.transfer(request2.player, request1.amount + request2.amount);
            emit Transfer(request2.player, request1.amount + request2.amount);
        }

        // Return the winner's ID
        return winnerId;
    }

    // Function to battle two Pepes
    function battle(BattleRequest memory request1, BattleRequest memory request2) internal returns (uint256) {
        // Get the attributes of the Pepes
        (uint256 appearance1, uint256 accessories1) = pepes.getPepeAttributes(request1.pepeId);
        (uint256 appearance2, uint256 accessories2) = pepes.getPepeAttributes(request2.pepeId);

        // Calculate the scores for the Pepes
        uint256 score1 = appearance1 + accessories1;
        uint256 score2 = appearance2 + accessories2;

        // Add some randomness to the scores
        uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, request1.player, request1.pepeId, request2.pepeId)));
        uint256 luckFactor = randNonce % 11;  // generate a luck factor between 0 and 10
        score1 += luckFactor;
        score2 += 10 - luckFactor; // so the total sum of luck remains the same for both players

        uint256 winnerId;

        // Determine the winner
        if (score1 > score2) {
            winnerId = request1.pepeId;
        } else {
            winnerId = request2.pepeId;
        }

        // Emit the Battle event
        emit Battle(request1.player, request2.player, request1.pepeId, request2.pepeId, winnerId);

        // Return the winner's ID
        return winnerId;
    }
}
