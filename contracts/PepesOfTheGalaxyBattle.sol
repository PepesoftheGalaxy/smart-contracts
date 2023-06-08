// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPepesOfTheGalaxyNFT {
    function getPepeAttributes(uint256 _tokenId) external view returns (uint256 appearance, uint256 accessories);
    function addExperience(uint256 _tokenId, uint256 experience) external; 
}

contract PepesOfTheGalaxyBattle is Ownable {
    IPepesOfTheGalaxyNFT public pepeNFT;
    IERC20 public pepeToken;

    struct BattleRequest {
        uint256 pepeId;
        uint256 amount;
        address player;
    }

    BattleRequest[] private battleQueue;
    uint256 private front = 0;
    uint256 private rear = 0;

    event StakedForBattle(uint256 indexed pepeId, uint256 amount, address indexed player);
    event BattleOutcome(address indexed player1, address indexed player2, uint256 pepe1Id, uint256 pepe2Id, uint256 winnerId);

    constructor(address _pepeNFT, address _pepeToken) {
        pepeNFT = IPepesOfTheGalaxyNFT(_pepeNFT);
        pepeToken = IERC20(_pepeToken);
    }

    function stake(uint256 _pepeId, uint256 _amount) public {
        require(pepeToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(pepeToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        require(pepeToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        // Enqueue
        if(rear == battleQueue.length) {
            battleQueue.push(BattleRequest(_pepeId, _amount, msg.sender));
        } else {
            battleQueue[rear] = BattleRequest(_pepeId, _amount, msg.sender);
        }
        rear++;

        emit StakedForBattle(_pepeId, _amount, msg.sender);

        if (queueLength() >= 2) {
            battle();
        }
    }

    function battle() private {
        require(queueLength() >= 2, "Not enough players");

        BattleRequest memory player1 = battleQueue[front];
        BattleRequest memory player2 = battleQueue[front + 1];

        (uint256 p1Attr1, uint256 p1Attr2) = pepeNFT.getPepeAttributes(player1.pepeId);
        (uint256 p2Attr1, uint256 p2Attr2) = pepeNFT.getPepeAttributes(player2.pepeId);

        // Calculate luck factor (for production use Chainlink VRF for critical randomness)
        uint256 randNonce = uint256(keccak256(abi.encodePacked(block.timestamp, player1.player, player1.pepeId, player2.pepeId)));
        uint256 luckFactor = randNonce % 11;
        p1Attr1 += luckFactor;
        p2Attr1 += luckFactor;

        // Determine the winner
        address winner;
        uint256 winnerPepeId;
        uint256 totalAmount = player1.amount + player2.amount;
        if (p1Attr1 + p1Attr2 > p2Attr1 + p2Attr2) {
            winner = player1.player;
            winnerPepeId = player1.pepeId;
        } else {
            winner = player2.player;
            winnerPepeId = player2.pepeId;
        }

        // Dequeue and Shift array (efficient dequeue)
        front += 2;

        // Interact with external contract after state changes
        pepeToken.transfer(winner, totalAmount);

        emit BattleOutcome(player1.player, player2.player, player1.pepeId, player2.pepeId, winnerPepeId);
    }

    function queueLength() private view returns (uint256) {
        return rear - front;
    }
}
