pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PepesOfTheGalaxy is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("PepesOfTheGalaxy", "POTG") public {
    }

    function mintPepe(address player, string memory tokenURI) public payable returns (uint256) {
        require(msg.value == 50 ether, "Minting a Pepe costs 50 MATIC");

        _tokenIds.increment();

        uint256 newPepeId = _tokenIds.current();
        _mint(player, newPepeId);
        _setTokenURI(newPepeId, tokenURI);

        return newPepeId;
    }
}
