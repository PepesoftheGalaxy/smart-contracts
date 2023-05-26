// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Importing required OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  // ERC20 interface
import "@openzeppelin/contracts/access/Ownable.sol";  // Owner functionality

// The main contract for the PepesOfTheGalaxy token
contract PepesOfTheGalaxy is Ownable, ERC20 {

    // The maximum and minimum amount of tokens that can be held by an address
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;

    // Address of the Uniswap pair for this token
    address public uniswapV2Pair;

    // Indicates if trading limit is active
    bool public limited;

    // The constructor function runs once upon contract creation
    constructor(uint256 _totalSupply) ERC20("Pepes of the Galaxy", "PEPEG") {
        // Mint the total supply to the creator of the contract
        _mint(msg.sender, _totalSupply);
    }

    // Function to set rules for trading. Only callable by the owner
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }

    // Function that runs before any token transfer. Overridden from ERC20 contract
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) override internal virtual {
        // If the Uniswap pair has not been set, only allow transfers from or to the owner
        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading is not started");
            return;
        }
        // If trading limit is active and tokens are being bought from Uniswap, check holding restrictions
        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
        }
    }

    // Public function to burn tokens from caller's balance
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
