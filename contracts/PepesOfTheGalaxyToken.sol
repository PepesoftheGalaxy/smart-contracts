// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the ERC20 and Ownable contracts from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// PepesOfTheGalaxyToken is a custom token that extends the ERC20 and Ownable contracts
contract PepesOfTheGalaxyToken is Ownable, ERC20 {
    // Public variables that can be read from outside the contract
    uint256 public maxHoldingAmount; // The maximum amount of tokens a single address can hold
    uint256 public minHoldingAmount; // The minimum amount of tokens a single address must hold
    address public uniswapV2Pair; // The Uniswap v2 pair for this token
    bool public limited; // Boolean variable to check if token transfers are limited

    // Events
    event RulesSet(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount);

    // Constructor function that is called once when the contract is deployed
    constructor(uint256 _totalSupply) ERC20("Pepes of the Galaxy", "PEPEOG") {
        _mint(msg.sender, _totalSupply); // Mint the initial total supply to the contract deployer
    }

    // Function to set the trading rules for the token
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited; // Set whether token transfers are limited
        uniswapV2Pair = _uniswapV2Pair; // Set the Uniswap v2 pair for this token
        maxHoldingAmount = _maxHoldingAmount; // Set the maximum holding amount
        minHoldingAmount = _minHoldingAmount; // Set the minimum holding amount
        emit RulesSet(_limited, _uniswapV2Pair, _maxHoldingAmount, _minHoldingAmount); // Emit the RulesSet event
    }

    // Internal function that is called before any transfer of tokens
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        // If trading is not started, only allow transfers from or to the owner
        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading is not started");
        }
        // If token transfers are limited and tokens are being bought from Uniswap, check the holding restrictions
        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
        }
    }

    // Function to transfer the ownership of the contract
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Invalid new owner"); // The new owner's address must not be the zero address
        super.transferOwnership(newOwner); // Transfer the ownership to the new address
    }
}
