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



# PepesOfTheGalaxyLaunchPool Smart Contract

The `PepesOfTheGalaxyLaunchPool` contract is a staking contract that allows users to stake BNB (or ETH) and earn rewards in the form of `PepesOfTheGalaxyToken`.

## Key Features

- **Staking**: Users can stake BNB (or ETH) by calling the `stake` function. The staked amount is recorded in the `stakes` mapping, and the total staked amount is updated.

- **Time-based Rewards**: The contract calculates rewards based on the amount staked and the time staked. The longer the staking period, the higher the rewards. This is achieved using a bonding curve.

- **Claiming and Withdrawing**: Users can claim their rewards and withdraw their staked amount after the staking period by calling the `claimAndWithdraw` function.

- **Pausing and Unpausing**: The contract owner can pause or unpause the contract by calling the `pause` and `unpause` functions. This is useful for stopping the contract in case of emergencies.

## Key Variables

- `stakes`: A mapping that records the amount of BNB (or ETH) staked by each user.
- `stakeTime`: A mapping that records the time when each user staked their tokens.
- `totalStaked`: The total amount of BNB (or ETH) staked by all users.
- `token`: The `PepesOfTheGalaxyToken` token that users earn as rewards.
- `STAKING_PERIOD`: The duration of the staking period.
- `stakingStart`: The time when the staking period starts.
- `stakingEnd`: The time when the staking period ends.
- `FEE_PERCENT`: The fee percentage charged on the staked amount.
- `feeRecipient`: The address that receives the fee.

## Key Functions

- `constructor`: Initializes the contract with the token address, staking start time, and fee recipient address.
- `stake`: Allows users to stake BNB (or ETH). The staked amount is recorded and the total staked amount is updated.
- `claimAndWithdraw`: Allows users to claim their rewards and withdraw their staked amount after the staking period.
- `pause`: Allows the contract owner to pause the contract.
- `unpause`: Allows the contract owner to unpause the contract.