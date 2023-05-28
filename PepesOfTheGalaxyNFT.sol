pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PepesOfTheGalaxy is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable private gnosisMultisigWallet;

    event NewPepe(uint256 indexed pepeId, address indexed player, string tokenURI);

    constructor(address payable _gnosisMultisigWallet) ERC721("PepesOfTheGalaxy", "POTG") public {
        gnosisMultisigWallet = _gnosisMultisigWallet;
    }

    function mintPepe(address player, string memory tokenURI) public payable returns (uint256) {
        require(msg.value == 50 ether, "Minting a Pepe costs 50 MATIC");

        _tokenIds.increment();

        uint256 newPepeId = _tokenIds.current();
        _mint(player, newPepeId);
        _setTokenURI(newPepeId, tokenURI);

        // Emit the NewPepe event
        emit NewPepe(newPepeId, player, tokenURI);

        // Transfer the MATIC to the Gnosis multisig wallet
        gnosisMultisigWallet.transfer(msg.value);

        return newPepeId;
    }
}
