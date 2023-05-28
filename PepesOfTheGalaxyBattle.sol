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

    // Mapping of the stakes per user
    mapping(address => uint256) public stakes;

    // Reference to the Pepeg token contract (ERC20)
    ERC20 public pepegToken;

    // Event emitted when a user stakes their Pepe
    event Staked(address indexed user, uint256 pepeId, uint256 amount);

    // Event emitted when a battle occurs
    event Battle(address indexed user, uint256 pepeId1, uint256 pepeId2, uint256 winnerId);

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
        
        // Update the stake amount for this user
        stakes[msg.sender] = _amount;

        // Emit the Staked event
        emit Staked(msg.sender, _pepeId, _amount);
    }

    // Function to initiate a battle between two Pepes
    function battle(uint256 _pepeId1, uint256 _pepeId2) public returns (uint256) {
        // Make sure the user has staked some Pepeg tokens
        require(stakes[msg.sender] > 0, "Not staked");

        // Get the attributes of the Pepes
        (uint256 appearance1, uint256 accessories1) = pepes.getPepeAttributes(_pepeId1);
        (uint256 appearance2, uint256 accessories2) = pepes.getPepeAttributes(_pepeId2);

        // Calculate the scores for the Pepes
        uint256 score1 = appearance1 + accessories1;
        uint256 score2 = appearance2 + accessories2;

        // Add some randomness to the scores
        uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _pepeId1, _pepeId2)));
        uint256 luckFactor = randNonce % 11;  // generate a luck factor between 0 and 10
        score1 += luckFactor;
        score2 += 10 - luckFactor; // so the total sum of luck remains the same for both players

        uint256 winnerId;

        // Determine the winner
        if (score1 > score2) {
            winnerId = _pepeId1;
        } else {
            winnerId = _pepeId2;
        }

        // Transfer the staked Pepeg tokens back to the user
        pepegToken.transfer(msg.sender, stakes[msg.sender]);
        
        // Emit the Transfer event
        emit Transfer(msg.sender, stakes[msg.sender]);

        // Reset the user's stake
        stakes[msg.sender] = 0;

        // Emit the Battle event
        emit Battle(msg.sender, _pepeId1, _pepeId2, winnerId);

        // Return the winner's ID
        return winnerId;
    }
}
