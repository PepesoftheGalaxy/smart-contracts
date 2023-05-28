// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PepesOfTheGalaxy is Ownable, ERC20 {
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    bool public limited;
    uint256 private tokenCap;

    // Constructor function that initializes the contract
    constructor(uint256 _totalSupply, uint256 _tokenCap) ERC20("Pepes of the Galaxy", "PEPEG") {
        _mint(msg.sender, _totalSupply);
        tokenCap = _tokenCap;
    }

    // Function to set trading rules for the contract, callable only by the owner
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }

    // Internal function that runs before any token transfer
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
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

    // External function to burn tokens from caller's balance
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }

// Function to transfer ownership of the contract to a new address, callable only by the owner
function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Invalid new owner");
    super.transferOwnership(newOwner);
}

    // Function to mint new tokens, callable only by the owner
    function mint(address account, uint256 amount) external onlyOwner {
        // Check if the token cap would be exceeded by minting new tokens
        require(totalSupply() + amount <= tokenCap, "Token cap exceeded");
        _mint(account, amount);
    }
}
