# PepesOfTheGalaxy Smart Contracts 🌌🚀

## Contents
- [PepesOfTheGalaxyToken Smart Contract](#pepesofthegalaxytoken-smart-contract)
- [PepesOfTheGalaxyLaunchPool Smart Contract](#pepesofthegalaxylaunchpool-smart-contract)

## PepesOfTheGalaxyToken Smart Contract 🪙

The `PepesOfTheGalaxyToken` contract is a custom ERC20 token contract that includes additional features such as ownership and transfer restrictions.

### Key Features 🌟

- **ERC20 Token**: Implements standard functions (`balanceOf`, `transfer`, etc.) and events (`Transfer`, `Approval`) of the ERC20 standard.

- **Ownable**: Has an owner (usually the deployer) with special privileges, enforced by the `onlyOwner` modifier.

- **Transfer Restrictions**: Features limits on token transfers. When `limited` is `true`, transfers are subject to `maxHoldingAmount` and `minHoldingAmount` constraints.

- **Uniswap Integration**: Utilizes the `uniswapV2Pair` variable to store the address of the Uniswap V2 pair. This plays a key role in enforcing transfer rules, especially when tokens are bought from Uniswap. The contract checks whether a transfer aligns with the set maximum or minimum holding amounts by comparing the sender's address with the `uniswapV2Pair` address. This ensures equitable token distribution and prevents concentration of holdings.

### Key Variables 🔑

- `maxHoldingAmount`: Maximum tokens a single address can hold.
- `minHoldingAmount`: Minimum tokens a single address must hold.
- `uniswapV2Pair`: Address of the Uniswap V2 pair, crucial for enforcing transfer restrictions during purchases from Uniswap.
- `limited`: Indicates if token transfers are restricted.

### Key Functions 🛠️

- `constructor`: Initializes with total supply minted to the sender.
- `setRule`: Lets the owner set trading rules (transfer limits, Uniswap pair, holding amounts).
- `_beforeTokenTransfer`: Internal function to enforce trading rules before any transfer.
- `transferOwnership`: Transfers contract ownership.

### Events 📢

- `RulesSet`: Triggered when trading rules are set.

### Real-Life Example 🌍

Launching **PepesOfTheGalaxyToken** with 1 million tokens involves:

1. **Deploying the contract** with 1 million tokens minted to the deployer.
2. **Setting trading rules**, including the `uniswapV2Pair` for purchase validations.

The `uniswapV2Pair` is critical in ensuring compliance with holding limits, particularly for Uniswap-based transactions. This facilitates a balanced token distribution and adherence to the set maximum and minimum holding requirements.

## PepesOfTheGalaxyLaunchPool Smart Contract 🏊‍♂️

The `PepesOfTheGalaxyLaunchPool` contract is a staking contract that allows users to stake BNB (or ETH) and earn rewards in the form of `PepesOfTheGalaxyToken`.

### Key Features 🌟

- **Staking**: Users can stake BNB (or ETH) by calling the `stake` function. The staked amount is recorded in the `stakes` mapping, and the total staked amount is updated.

- **Time-based Rewards**: The contract calculates rewards based on the amount staked and the time staked. The longer the staking period, the higher the rewards. This is achieved using a bonding curve.

- **Claiming and Withdrawing**: Users can claim their rewards and withdraw their staked amount after the staking period by calling the `claimAndWithdraw` function.

- **Pausing and Unpausing**: The contract owner can pause or unpause the contract by calling the `pause` and `unpause` functions. This is useful for stopping the contract in case of emergencies.

### Key Variables 🔑

- `stakes`: A mapping that records the amount of BNB (or ETH) staked by each user.
- `stakeTime`: A mapping that records the time when each user staked their tokens.
- `totalStaked`: The total amount of BNB (or ETH) staked by all users.
- `token`: The `PepesOfTheGalaxyToken` token that users earn as rewards.
- `STAKING_PERIOD`: The duration of the staking period.
- `stakingStart`: The time when the staking period starts.
- `stakingEnd`: The time when the staking period ends.
- `FEE_PERCENT`: The fee percentage charged on the staked amount.
- `feeRecipient`: The address that receives the fee.

### Key Functions 🛠️

- `constructor`: Initializes the contract with the token address, staking start time, and fee recipient address.
- `stake`: Allows users to stake BNB (or ETH). The staked amount is recorded and the total staked amount is updated.
- `claimAndWithdraw`: Allows users to claim their rewards and withdraw their staked amount after the staking period.
- `pause`: Allows the contract owner to pause the contract.
- `unpause`: Allows the contract owner to unpause the contract.
