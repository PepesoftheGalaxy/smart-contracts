Sure, I can help create a basic SDK to interact with the contracts. This SDK will use `ethers.js`, a popular JavaScript library for interacting with Ethereum contracts. Please note that this SDK assumes you have the addresses for your deployed contracts and a provider connected to the Ethereum network.

```javascript
const ethers = require('ethers');

class PepesOfTheGalaxySDK {
    constructor(pepeNFTAddress, pepeBattleAddress, pepeTokenAddress, provider, signer) {
        const pepeNFTABI = [...]; // Replace with the ABI of the PepesOfTheGalaxyNFT contract
        const pepeBattleABI = [...]; // Replace with the ABI of the PepesOfTheGalaxyBattle contract
        const pepeTokenABI = [...]; // Replace with the ABI of the ERC20 token contract (pepeToken)

        this.pepeNFTContract = new ethers.Contract(pepeNFTAddress, pepeNFTABI, signer);
        this.pepeBattleContract = new ethers.Contract(pepeBattleAddress, pepeBattleABI, signer);
        this.pepeTokenContract = new ethers.Contract(pepeTokenAddress, pepeTokenABI, signer);
    }

    async mintPepe(tokenURI, appearance, accessories) {
        const mintTx = await this.pepeNFTContract.mintPepe(msg.sender, tokenURI, appearance, accessories, { value: ethers.utils.parseEther('50') });
        await mintTx.wait();
    }

    async getPepeAttributes(tokenId) {
        const attributes = await this.pepeNFTContract.getPepeAttributes(tokenId);
        return attributes;
    }

    async stakeForBattle(pepeId, amount) {
        const amountInWei = ethers.utils.parseUnits(amount.toString(), 'wei');
        const approveTx = await this.pepeTokenContract.approve(this.pepeBattleContract.address, amountInWei);
        await approveTx.wait();
        const stakeTx = await this.pepeBattleContract.stake(pepeId, amountInWei);
        await stakeTx.wait();
    }

    async initiateBattle() {
        const tx = await this.pepeBattleContract.battle();
        await tx.wait();
    }
}

// Usage
const provider = new ethers.providers.JsonRpcProvider('http://localhost:8545');
const signer = provider.getSigner();

const pepeSDK = new PepesOfTheGalaxySDK(
    'PEPES_OF_THE_GALAXY_NFT_ADDRESS',
    'PEPES_OF_THE_GALAXY_BATTLE_ADDRESS',
    'PEPE_TOKEN_ADDRESS',
    provider,
    signer
);
```

In the above example, replace `'PEPES_OF_THE_GALAXY_NFT_ADDRESS'`, `'PEPES_OF_THE_GALAXY_BATTLE_ADDRESS'`, and `'PEPE_TOKEN_ADDRESS'` with the addresses of your deployed contracts.

Please note the following:

1. This SDK assumes that the signer is already connected to a provider (e.g., MetaMask or a local Ethereum node) and has enough funds to mint Pepes and stake for battles.

2. `mintPepe` function assumes that the signer is sending 50 Ether (or MATIC, depending on the network) with the transaction, which is required by the `mintPepe` function in the smart contract.

3. `stakeForBattle` function assumes that the signer has already approved the transfer of `pepeToken` to the `PepesOfTheGalaxyBattle` contract.

4. In the real-world application, you might want to handle events emitted by these contracts for a better user experience. For example, you can listen to `NewPepe` event to notify the user when a new

Pepe is minted, or `BattleOutcome` event to notify the user of the result of a battle.

```javascript
this.pepeNFTContract.on('NewPepe', (pepeId, player, tokenURI, event) => {
    // Handle the event
    console.log(`New Pepe with id ${pepeId} minted for player ${player}`);
});

this.pepeBattleContract.on('BattleOutcome', (winner, loser, amount, event) => {
    // Handle the event
    console.log(`Battle finished. Winner: ${winner}, Loser: ${loser}, Amount won: ${amount}`);
});
```

5. Error handling has been left out for simplicity, but in a real-world application, you should add try/catch blocks to handle any errors that might occur during transactions.

6. The ABIs for the contracts (`pepeNFTABI`, `pepeBattleABI`, and `pepeTokenABI`) have to be provided. The ABI (Application Binary Interface) is a JSON representation of your contract (including all of its functions and variables) that allows JavaScript to interact with the contract. You can get the ABI from your contract compilation output.

7. Always make sure to handle private keys and other sensitive information securely. In this example, it is assumed that the signer is provided securely and has been unlocked with the appropriate private key. Never expose private keys in your code.

Please ensure to modify and enhance this code according to your needs and handle all edge cases and errors appropriately for your specific use-case.