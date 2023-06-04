// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PepesOfTheGalaxyNFT is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public constant EXPERIENCE_UPDATER_ROLE = keccak256("EXPERIENCE_UPDATER_ROLE");
    address payable private gnosisMultisigWallet;

    struct PepeMetadata {
        uint256 appearance;
        uint256 accessories;
        uint256 experience;
    }

    mapping(uint256 => PepeMetadata) public tokenMetadata;

    event NewPepe(uint256 indexed pepeId, address indexed player, string tokenURI);
    event ExperienceUpdated(uint256 indexed pepeId, uint256 experience); // Added event

    constructor(address payable _gnosisMultisigWallet) ERC721("PepesOfTheGalaxy", "POTG") {
        gnosisMultisigWallet = _gnosisMultisigWallet;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mintPepe(address player, string memory tokenURI, uint256 appearance, uint256 accessories) public payable returns (uint256) {
        require(msg.value == 0.05 ether, "Minting a Pepe costs 50 MATIC");
        _tokenIds.increment();
        uint256 newPepeId = _tokenIds.current();
        _mint(player, newPepeId);
        _setTokenURI(newPepeId, tokenURI);
        tokenMetadata[newPepeId] = PepeMetadata({
            appearance: appearance,
            accessories: accessories,
            experience: 0
        });
        emit NewPepe(newPepeId, player, tokenURI);
        gnosisMultisigWallet.transfer(msg.value);
        return newPepeId;
    }

    function getPepeAttributes(uint256 _tokenId) public view returns (uint256 appearance, uint256 accessories, uint256 experience) {
    require(_exists(_tokenId), "Pepe does not exist");
    PepeMetadata storage metadata = tokenMetadata[_tokenId];
    return (metadata.appearance, metadata.accessories, metadata.experience);
    }

    function addExperience(uint256 _tokenId, uint256 experience) public {
        require(hasRole(EXPERIENCE_UPDATER_ROLE, msg.sender), "Caller is not allowed to update experience");
        PepeMetadata storage metadata = tokenMetadata[_tokenId];
        metadata.experience += experience;
        emit ExperienceUpdated(_tokenId, metadata.experience); // Emit the event when experience is updated
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}