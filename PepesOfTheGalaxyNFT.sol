pragma solidity ^0.8.0;

// Importing necessary components from the OpenZeppelin library
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Define the NFT contract, inheriting from the ERC721 contract (standard for NFTs) and the AccessControl contract for role-based access control
contract PepesOfTheGalaxyNFT is ERC721, AccessControl {
    using Counters for Counters.Counter;
    // Use Counters library for managing token IDs

    Counters.Counter private _tokenIds;
    // Counter for token IDs

    // Define a role for the contract that is allowed to update experience
    bytes32 public constant EXPERIENCE_UPDATER_ROLE = keccak256("EXPERIENCE_UPDATER_ROLE");

    // Define a private payable address for the gnosis multisig wallet
    address payable private gnosisMultisigWallet;

    // Define the structure of the Pepe Metadata
    struct PepeMetadata {
        uint256 appearance;
        uint256 accessories;
        uint256 experience;
    }

    // Map token IDs to PepeMetadata
    mapping(uint256 => PepeMetadata) public tokenMetadata;

    // Event to be emitted when a new Pepe is minted
    event NewPepe(uint256 indexed pepeId, address indexed player, string tokenURI);

    constructor(address payable _gnosisMultisigWallet) ERC721("PepesOfTheGalaxy", "POTG") public {
        // Set the gnosis multisig wallet
        gnosisMultisigWallet = _gnosisMultisigWallet;

        // Set the sender (deployer) as the default admin role
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Function to mint a new Pepe
    function mintPepe(address player, string memory tokenURI, uint256 appearance, uint256 accessories) public payable returns (uint256) {
        // Require that the correct minting fee is attached
        require(msg.value == 50 ether, "Minting a Pepe costs 50 MATIC");

        // Increment token IDs
        _tokenIds.increment();

        // Get the current token ID
        uint256 newPepeId = _tokenIds.current();

        // Mint the new token to the player
        _mint(player, newPepeId);

        // Set the token URI
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

        // Return the new Pepe ID
        return newPepeId;
    }

    // Function to get a Pepe's attributes
    function getPepeAttributes(uint256 _tokenId) public view returns (uint256 appearance, uint256 accessories, uint256 experience) {
        // Retrieve the metadata for the given token ID
        PepeMetadata storage metadata = tokenMetadata[_tokenId];

        // Return the attributes of the Pepe
        return (metadata.appearance, metadata.accessories, metadata.experience);
    }

    // Function to add experience to a Pepe
    function addExperience(uint256 _tokenId, uint256 experience) public {
        // Require that the caller has the EXPERIENCE_UPDATER_ROLE
        require(hasRole(EXPERIENCE_UPDATER_ROLE, msg.sender), "Caller is not allowed to update experience");

        // Get the metadata for the Pepe
        PepeMetadata storage metadata = tokenMetadata[_tokenId];

        // Add the experience to the Pepe
        metadata.experience += experience;
    }
}
