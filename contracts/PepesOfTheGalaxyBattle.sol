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
    event StakedForBattle(uint256 indexed pepeId, uint256 amount, address indexed player);
    event BattleOutcome(address indexed player1, address indexed player2, uint256 pepe1Id, uint256 pepe2Id, uint256 winnerId);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event TransferSucceeded(bool success);

    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IPepesOfTheGalaxyNFT(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

    // Stake a specific amount of tokens with a specific NFT
    function stake(uint256 _pepeId, uint256 _amount) public {
        // Check the player's balance
        require(pepeToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        // Check the player's allowance for the battle contract
        require(pepeToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");

        // Transfer tokens to this contract
        require(pepeToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        // Add battle request
        BattleRequest memory newRequest;
        newRequest.pepeId = _pepeId;
        newRequest.amount = _amount;
        newRequest.player = msg.sender;
        battleRequests.push(newRequest);

        emit StakedForBattle(_pepeId, _amount, msg.sender);

        // Automatically start a battle if there are at least two players
        if (battleRequests.length >= 2) {
            battle();
        }
    }

    // Battle function
    function battle() public {
    require(battleRequests.length >= 2, "Not enough players");

    // Get the first two players
    BattleRequest memory player1 = battleRequests[0];
    BattleRequest memory player2 = battleRequests[1];

    // Get the attributes of the two pepes
    (uint256 p1Attr1, uint256 p1Attr2) = pepeNFT.getPepeAttributes(player1.pepeId);
    (uint256 p2Attr1, uint256 p2Attr2) = pepeNFT.getPepeAttributes(player2.pepeId);

    // Calculate luck factor
    uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, player1.player, player1.pepeId, player2.pepeId)));
    uint256 luckFactor = randNonce % 11;
    p1Attr1 += luckFactor;
    p2Attr1 += luckFactor;

    // Determine the winner
    uint256 winnerId;
    bool transferSucceeded;
    if (p1Attr1 + p1Attr2 > p2Attr1 + p2Attr2) {
        winnerId = player1.pepeId;
        transferSucceeded = pepeToken.transfer(player1.player, player1.amount + player2.amount);
        pepeNFT.addExperience(player1.pepeId, 2);
        pepeNFT.addExperience(player2.pepeId, 1);
    } else {
        winnerId = player2.pepeId;
        transferSucceeded = pepeToken.transfer(player2.player, player1.amount + player2.amount);
        pepeNFT.addExperience(player2.pepeId, 2);
        pepeNFT.addExperience(player1.pepeId, 1);
    }

    // Emit the battle outcome event with the winner and their attributes
    emit BattleOutcome(player1.player, player2.player, player1.pepeId, player2.pepeId, winnerId);

    // Log the outcome of the transfer
    emit TransferSucceeded(transferSucceeded);

    // Remove the two players from the battle requests array
    delete battleRequests[0];
    delete battleRequests[1];

    // Shift array to left by 2 positions
    for (uint256 i = 0; i < battleRequests.length - 2; i++) {
        battleRequests[i] = battleRequests[i + 2];
    }

    // Pop last 2 elements
    if (battleRequests.length > 1) {
        battleRequests.pop();
        battleRequests.pop();
    }
  }


    function numPlayers() public view returns (uint256) {
        return battleRequests.length;
    }
}