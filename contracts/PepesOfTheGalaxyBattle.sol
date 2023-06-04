// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

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
    event StakedForBattle(uint256 indexed pepeId, uint256 amount, address indexed player);
    event BattleOutcome(address indexed player1, address indexed player2, uint256 pepe1Id, uint256 pepe2Id, uint256 winnerId);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IPepesOfTheGalaxyNFT(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

  // Stake a specific amount of tokens with a specific NFT
function stake(uint256 _pepeId, uint256 _amount) public {
    // Transfer tokens to this contract
    require(pepeToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

    // Add battle request
    BattleRequest memory newRequest;
    newRequest.pepeId = _pepeId;
    newRequest.amount = _amount;
    newRequest.player = msg.sender;
    battleRequests.push(newRequest);

    emit StakedForBattle(_pepeId, _amount, msg.sender);
}

    // Battle function
    function battle() public onlyOwner {
        require(battleRequests.length >= 2, "Not enough players");

        // Get the first two players
        BattleRequest memory player1 = battleRequests[0];
        BattleRequest memory player2 = battleRequests[1];

        // Get the attributes of the two pepes
        (uint256 p1Attr1, uint256 p1Attr2) = pepeNFT.getPepeAttributes(player1.pepeId);
        (uint256 p2Attr1, uint256 p2Attr2) = pepeNFT.getPepeAttributes(player2.pepeId);

        // Determine the winner
        uint256 winnerId;
        if (p1Attr1 + p1Attr2 > p2Attr1 + p2Attr2) {
            winnerId = player1.pepeId;
            // Transfer the staked tokens to the winner
            require(pepeToken.transfer(player1.player, player1.amount + player2.amount), "Token transfer failed");
        } else {
            winnerId = player2.pepeId;
            // Transfer the staked tokens to the winner
            require(pepeToken.transfer(player2.player, player1.amount + player2.amount), "Token transfer failed");
        }

        // Emit the battle event
        emit BattleOutcome(player1.player, player2.player, player1.pepeId, player2.pepeId, winnerId);


        // Remove the first two battle requests
        for (uint256 i = 0; i < battleRequests.length - 2; i++) {
            battleRequests[i] = battleRequests[i + 2];
        }
        battleRequests.pop();
        battleRequests.pop();
    }
}
