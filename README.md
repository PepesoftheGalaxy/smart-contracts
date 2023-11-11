# Pepes of the Galaxy Game

## Introduction

Pepes of the Galaxy is a unique, whimsical, and engaging decentralized game that takes place in the infinite reaches of the cosmos. The game revolves around a species known as Pepes, who evolved on a vibrant planet known as Peponia. Each Pepe possesses unique attributes and quirky accessories, with each feature telling a unique story of their lineage.

## The Game Mechanics

The game mechanics are built around a series of smart contracts that govern the rules and interactions within the game. These contracts include:

- **PepesOfTheGalaxyToken.sol**: This contract defines the Pepenite (PEPEOG) token, the in-game currency. Players can earn, stake, and wager these tokens in various game activities.

- **PepesOfTheGalaxyNFT.sol**: This contract manages the Non-Fungible Tokens (NFTs) representing the Pepes. Each Pepe is unique and has its own set of attributes (appearance, accessories, and experience).

- **PepesOfTheGalaxyLaunchPool.sol**: This contract manages the fair launch of PEPEOG tokens. Players can stake BNB and ETH tokens to earn PEPEOG.

- **PepesOfTheGalaxyBattle.sol**: This contract manages the battles between Pepes. Players can wager their PEPEOG tokens in these battles, with the winner claiming the wagered tokens.
- **PepesOfTheGalaxyNFTStaking.sol**: This contract allows players to stake their Pepe NFTs to earn PEPEOG tokens.

## Token Economics

The PEPEOG token is the lifeblood of the Pepes of the Galaxy game. It serves as the in-game currency and is used for various activities such as staking, participating in battles, and governance.

The token is being launched in a fair manner, with the team getting no tokens. This ensures a level playing field for all participants and aligns the interests of the team with the success of the game.

A 2.5% fee is charged on the launchpool, which goes directly to the game treasury. This treasury is used to fund the ongoing development and maintenance of the game. 

The proceeds from the minting of the NFTs also go to the game treasury, providing another source of funding for the game.

A 10% fee is charged on each battle, which goes to the game treasury. This fee on the battles helps to fund the rewards and incentives in the game.

The PEPEOG tokens can also be used in governance, allowing token holders to vote on the growth and development of the game. This ensures that the game evolves in a way that benefits the players and aligns with their interests.

## Token Model

The PEPEOG token allocation is structured to ensure long-term sustainability and equitable distribution among various stakeholders in the game ecosystem. The allocation is as follows:

| Allocation Category          | Percentage | Purpose                                                               | Lockups                                 |
| ---------------------------- | ---------- | --------------------------------------------------------------------- | --------------------------------------- |
| In Game Rewards              | 40%        | Allocated for player rewards, including staking, battles, and participation incentives. | No lockup; distributed as per game rules |
| Development Fund             | 20%        | Reserved for ongoing development, operational expenses, and future enhancements. | Linear release over 2 years |
| Marketing and Partnerships   | 10%        | Used for marketing campaigns, strategic partnerships, and expanding the game's reach. | 6-month cliff, then linear release over 18 months |
| Launchpool                   | 10%        | Utilized for staking in the `PepesOfTheGalaxyLaunchPool`. This contract allows staking of BNB and ETH to get PEPEOG at launch, with a 2.5% fee on staked BNB and ETH, and rewards based on stake amount and duration, including bonus rewards calculated using a bonding curve. | No lockup; rewards distributed after staking period |
| Liquidity Provision          | 10%        | Reserved for providing liquidity in decentralized exchanges to facilitate trading of PEPEOG tokens. | No lockup |
| Airdrops and Community Initiatives | 10%  | Dedicated to airdrops, community engagement activities, and other initiatives to grow the player base. | No lockup; distributed during community events |

This allocation model is designed to balance the needs of immediate game functionality with long-term development and community engagement.

## Gameplay

The gameplay is centered around the ancient prophecy that foretold a great challenge that would sweep across the galaxy. The prophecy stated, "When the planets align, the Galaxy Gates will open, and the Pepes will embark on a journey to claim their place in the galaxy."

Players can participate in the game by owning and staking PEPEOG tokens and Pepe NFTs. They can earn more tokens by staking their existing tokens, participating in battles, and staking their Pepe NFTs.

The battles are not merely tests of strength but also of luck. Even the most humble Pepe could best the strongest contender with a stroke of fortune. Each battle levels up a Pepe's experience, making them stronger and more valuable.

As the Pepes continue their journey, they evolve, their appearances becoming grander, and their accessories more resplendent. The ultimate goal is to emerge as the guardian of the galaxy.

## Development Roadmap

The development roadmap for Pepes of the Galaxy extends over the next 12 months and includes several exciting milestones:

- **Month 1**: Launch of the PEPEOG token and the staking pool. An airdrop of PEPEOG tokens will be conducted to kickstart the game economy.

- **Month 3**: Launch of the Pepe NFT sale and the first battle contract. Players can now buy Pepe NFTs and participate in battles. The NFTs will be available for trading on OpenSea.

- **Month 5**: Introduction of new battle arenas and special edition Pepes. These new additions will provide more variety and excitement to the game.

- **Month 7**: Launch of the governance module. PEPEOG token holders can now vote on proposals and influence the direction of the game.

- **Month 9**: Introduction of new game modes and challenges. These new modes will provide more ways for players to earn rewards and level up their Pepes.

- **Month 11**: Launch of the Pepe accessory marketplace. Players can now buy, sell, and trade their Pepe accessories, adding another layer of customization and strategy to the game.

- **Month 12**: Introduction of a new storyline and quests. These new elements will add more depth to the game and provide players with new challenges to overcome.

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

## Conclusion

Pepes of the Galaxy is a decentralized game that combines the excitement of NFTs, the potential of DeFi, and the thrill of battles. It offers a unique and engaging gaming experience while also providing opportunities for players to earn rewards. The game's mechanics are governed by a series of smart contracts, ensuring transparency, fairness, and security. With a robust development roadmap and a fair token economy, Pepes of the Galaxy is set to become a leading game in the blockchain space.