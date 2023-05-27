# PepesOfTheGalaxy Smart Contract

## Overview

The PepesOfTheGalaxy contract is a custom ERC20 token contract, built with [OpenZeppelin](https://openzeppelin.com/) libraries. This contract allows the creation of a token with the name "Pepes of the Galaxy" and the symbol "PEPEG". It also includes additional features such as token burning, ownership transfer, and trading rules.

## Features

- **ERC20 Token**: The contract inherits from OpenZeppelin's ERC20 contract, which provides standard functions for a [ERC20 token](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/).

- **Ownable**: The contract also inherits from OpenZeppelin's Ownable contract. This contract provides basic access control mechanism, where there is an account (an owner) that can be granted exclusive access to certain functions.

- **Token Cap**: A cap on the total number of tokens that can be minted is implemented to prevent unlimited minting of tokens.

- **Trading Rules**: The contract includes an option to set trading rules which can limit the minimum and maximum amount of tokens that can be held by an address. This rule can be turned on and off.

- **Token Burning**: Users have the ability to burn their tokens, permanently removing them from the total supply.

## Functions

- **constructor(uint256 _totalSupply, uint256 _tokenCap)**: Initializes the contract, mints the total supply of tokens to the message sender, and sets the token cap.

- **setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount)**: Sets the trading rules for the contract. This function can only be called by the owner of the contract.

- **_beforeTokenTransfer(address from, address to, uint256 amount)**: A hook that runs before any token transfer. It checks the trading rules before allowing a transfer.

- **burn(uint256 value)**: Burns the specified number of tokens from the message sender's account.

- **transferOwnership(address newOwner)**: Transfers ownership of the contract to a new address. This function can only be called by the current owner of the contract.

- **mint(address account, uint256 amount)**: Mints new tokens to a specific address. This function can only be called by the owner of the contract.

## Security

The contract is built using well-audited OpenZeppelin contracts which follow best practices for contract security.