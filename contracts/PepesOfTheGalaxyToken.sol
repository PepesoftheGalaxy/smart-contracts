// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the ERC20, Ownable, and AccessControl contracts from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// PepesOfTheGalaxyToken is a custom token that extends the ERC20, Ownable, and AccessControl contracts
contract PepesOfTheGalaxyToken is Ownable, ERC20, AccessControl {
    // Public variables that can be read from outside the contract
    uint256 public maxHoldingAmount; // The maximum amount of tokens a single address can hold
    uint256 public minHoldingAmount; // The minimum amount of tokens a single address must hold
    address public uniswapV2Pair; // The Uniswap v2 pair for this token
    bool public limited; // Boolean variable to check if token transfers are limited
    uint256 private tokenCap; // The maximum total supply of the token
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // A constant for the minter role

    // Constructor function that is called once when the contract is deployed
    constructor(uint256 _totalSupply, uint256 _tokenCap) ERC20("Pepes of the Galaxy", "PEPEG") {
        _mint(msg.sender, _totalSupply); // Mint the initial total supply to the contract deployer
        tokenCap = _tokenCap; // Set the maximum total supply of the token
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Assign the default admin role to the contract deployer
    }

    // Function to set the trading rules for the token
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited; // Set whether token transfers are limited
        uniswapV2Pair = _uniswapV2Pair; // Set the Uniswap v2 pair for this token
        maxHoldingAmount = _maxHoldingAmount; // Set the maximum holding amount
        minHoldingAmount = _minHoldingAmount; // Set the minimum holding amount
    }

    // Internal function that is called before any transfer of tokens
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        // If trading is not started, only allow transfers from or to the owner
        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading is not started");
            return;
        }
        // If token transfers are limited and tokens are being bought from Uniswap, check the holding restrictions
        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
        }
    }

    // Function to burn tokens from the caller's balance
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Invalid new owner"); // The new owner's address must not be the zero address
        super.transferOwnership(newOwner); // Transfer the ownership to the new address
    }

    // Function to mint new tokens
    function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= tokenCap, "Token cap exceeded"); // The total supply after minting the new tokens must not exceed the token cap
        _mint(account, amount); // Mint the new tokens to the specified account
    }
}
