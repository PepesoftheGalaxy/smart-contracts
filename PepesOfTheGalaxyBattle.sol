// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interface for the Pepes contract (ERC721)
interface IPepes {
    function getPepeAttributes(uint256 _tokenId) external view returns (uint256 appearance, uint256 accessories);
    function addExperience(uint256 _tokenId, uint256 experience) external; // Adding new method in interface
}

contract PepesOfTheGalaxyBattle is Ownable {
    IPepes public pepes;
    ERC20 public pepegToken;

    struct BattleRequest {
        uint256 pepeId;
        uint256 amount;
        address player;
    }

    BattleRequest[] public battleRequests;

    event Staked(address indexed user, uint256 pepeId, uint256 amount);
    event Battle(address indexed user1, address indexed user2, uint256 pepeId1, uint256 pepeId2, uint256 winnerId);
    event Transfer(address indexed user, uint256 amount);

    constructor(address _pepegToken, address _pepes) {
        pepegToken = ERC20(_pepegToken);
        pepes = IPepes(_pepes);
    }

    function stake(uint256 _pepeId, uint256 _amount) public {
        require(pepegToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        battleRequests.push(BattleRequest(_pepeId, _amount, msg.sender));
        emit Staked(msg.sender, _pepeId, _amount);
        if (battleRequests.length >= 2) {
            matchPlayers();
        }
    }

    function matchPlayers() public returns (uint256) {
        require(battleRequests.length > 1, "Not enough players");
        BattleRequest storage request1 = battleRequests[battleRequests.length - 1];
        BattleRequest storage request2 = battleRequests[battleRequests.length - 2];
        battleRequests.pop();
        battleRequests.pop();

        uint256 winnerId = battle(request1, request2);

        if (winnerId == request1.pepeId) {
            pepegToken.transfer(request1.player, request1.amount + request2.amount);
            emit Transfer(request1.player, request1.amount + request2.amount);
        } else {
            pepegToken.transfer(request2.player, request1.amount + request2.amount);
            emit Transfer(request2.player, request1.amount + request2.amount);
        }

        return winnerId;
    }

    function battle(BattleRequest memory request1, BattleRequest memory request2) internal returns (uint256) {
        (uint256 appearance1, uint256 accessories1) = pepes.getPepeAttributes(request1.pepeId);
        (uint256 appearance2, uint256 accessories2) = pepes.getPepeAttributes(request2.pepeId);

        uint256 score1 = appearance1 + accessories1;
        uint256 score2 = appearance2 + accessories2;

        uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, request1.player, request1.pepeId, request2.pepeId)));
        uint256 luckFactor = randNonce % 11;  
        score1 += luckFactor;
        score2 += 10 - luckFactor; 

        uint256 winnerId;
        uint256 experience1 = 0;
        uint256 experience2 = 0;

        if (score1 > score2) {
            winnerId = request1.pepeId;
            experience1 += 10;
            experience2 += 5;
        } else {
            winnerId = request2.pepeId;
            experience2 += 10;
            experience1 += 5;
        }

        pepes.addExperience(request1.pepeId, experience1);
        pepes.addExperience(request2.pepeId, experience2);

        emit Battle(request1.player, request2.player, request1.pepeId, request2.pepeId, winnerId);
        return winnerId;
    }
}
