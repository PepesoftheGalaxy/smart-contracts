1. **Contract Initialization**: The contract is initialized with the address of the NFT contract and the ERC20 token contract that will be used for rewards. These addresses are stored in the `nft` and `rewardToken` variables respectively.

2. **Staking NFTs**: The `stake` function allows a user to stake their NFT. The function takes the `tokenId` as a parameter. It transfers the NFT from the user to the staking contract and records the current time as the start of the staking period for that user.

3. **Calculating Rewards**: The `calculateReward` internal function calculates the reward a user is due based on the time they have staked their NFT. It returns the full reward if the staking period has been a full 7 days or more, and zero otherwise.

4. **Withdrawing NFTs and Rewards**: The `withdraw` function allows a user to withdraw their staked NFT and any rewards they have earned. It first calculates the reward using `calculateReward`, then transfers the NFT back to the user, transfers the reward tokens to the user, and updates the user's reward balance in the contract.

5. **Querying Staked Time**: The `getStakingTime` function allows anyone to check how long a user's NFT has been staked. It subtracts the time the NFT was staked (`userStakedTime`) from the current time to get the total staking time.

6. **Event Emission**: The contract emits events when an NFT is staked (`Staked`) and when an NFT and rewards are withdrawn (`Withdrawn`). These events can be listened for off-chain to track the state of the contract.

7. **Rewards Balance**: The `userRewards` mapping keeps track of the total rewards each user has earned. When a user withdraws their NFT and rewards, their reward balance is updated.