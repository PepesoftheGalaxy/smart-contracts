pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PepesOfTheGalaxyNFT is ERC721, AccessControl {
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

    constructor(address payable _gnosisMultisigWallet) ERC721("PepesOfTheGalaxy", "POTG") public {
        gnosisMultisigWallet = _gnosisMultisigWallet;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);  // Set deployer as default admin role
    }

    function mintPepe(address player, string memory tokenURI, uint256 appearance, uint256 accessories) public payable returns (uint256) {
        require(msg.value == 50 ether, "Minting a Pepe costs 50 MATIC");

        _tokenIds.increment();

        uint256 newPepeId = _tokenIds.current();
        _mint(player, newPepeId);
        _setTokenURI(newPepeId, tokenURI);

        // Store the metadata on-chain
        tokenMetadata[newPepeId] = PepeMetadata({
            appearance: appearance,
            accessories: accessories,
            experience: 0
        });

        // Emit the NewPepe event
        emit NewPepe(newPepeId, player, tokenURI);

        // Transfer the MATIC to the Gnosis multisig wallet
        gnosisMultisigWallet.transfer(msg.value);

        return newPepeId;
    }

    function getPepeAttributes(uint256 _tokenId) public view returns (uint256 appearance, uint256 accessories, uint256 experience) {
        PepeMetadata storage metadata = tokenMetadata[_tokenId];
        return (metadata.appearance, metadata.accessories, metadata.experience);
    }

    function addExperience(uint256 _tokenId, uint256 experience) public {
        require(hasRole(EXPERIENCE_UPDATER_ROLE, msg.sender), "Caller is not allowed to update experience");
        PepeMetadata storage metadata = tokenMetadata[_tokenId];
        metadata.experience += experience;
    }
}
