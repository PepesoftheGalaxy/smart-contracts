pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPepes {
    function getPepeAttributes(uint256 _tokenId) external view returns (uint256 appearance, uint256 accessories);
}

contract PepesOfTheGalaxyBattle is Ownable {
    IPepes public pepes;
    mapping(address => uint256) public stakes;
    ERC20 public pepegToken;

    event Staked(address indexed user, uint256 pepeId, uint256 amount);
    event Battle(address indexed user, uint256 pepeId1, uint256 pepeId2, uint256 winnerId);
    event Transfer(address indexed user, uint256 amount);

    constructor(address _pepegToken, address _pepes) {
        pepegToken = ERC20(_pepegToken);
        pepes = IPepes(_pepes);
    }

    function stake(uint256 _pepeId, uint256 _amount) public {
        require(pepegToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        stakes[msg.sender] = _amount;
        emit Staked(msg.sender, _pepeId, _amount);
    }

    function battle(uint256 _pepeId1, uint256 _pepeId2) public returns (uint256) {
        require(stakes[msg.sender] > 0, "Not staked");
        (uint256 appearance1, uint256 accessories1) = pepes.getPepeAttributes(_pepeId1);
        (uint256 appearance2, uint256 accessories2) = pepes.getPepeAttributes(_pepeId2);
        
        uint256 score1 = appearance1 + accessories1;
        uint256 score2 = appearance2 + accessories2;
        uint256 winnerId;

        if (score1 > score2) {
            winnerId = _pepeId1;
        } else {
            winnerId = _pepeId2;
        }

        pepegToken.transfer(msg.sender, stakes[msg.sender]);
        emit Transfer(msg.sender, stakes[msg.sender]);
        stakes[msg.sender] = 0;
        emit Battle(msg.sender, _pepeId1, _pepeId2, winnerId);
        
        return winnerId;
    }
}
