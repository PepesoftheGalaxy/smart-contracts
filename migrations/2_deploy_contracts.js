const PepesOfTheGalaxyToken = artifacts.require('./PepesOfTheGalaxyToken.sol');
const PepesOfTheGalaxyNFT = artifacts.require('./PepesOfTheGalaxyNFT.sol');
const PepesOfTheGalaxyBattle = artifacts.require('PepesOfTheGalaxyBattle');
const PepesOfTheGalaxyNFTStaking = artifacts.require('./PepesOfTheGalaxyNFTStaking.sol');

module.exports = async function(deployer) {
  // Deploy the PepesOfTheGalaxyToken contract
  const initialSupply = web3.utils.toWei('8880000000', 'ether'); // Initial total supply of tokens
  await deployer.deploy(PepesOfTheGalaxyToken, initialSupply);
  const pepeToken = await PepesOfTheGalaxyToken.deployed();
  const pepeTokenAddress = pepeToken.address;

  // Deploy the PepesOfTheGalaxyNFT contract with the required parameter
  const gnosisMultisigWallet = '0x323bfFC91B1bF1fEd989af025732eeFfd262bb9e'; // Replace with the actual address of the multisig wallet
  await deployer.deploy(PepesOfTheGalaxyNFT, gnosisMultisigWallet);
  const pepeNFT = await PepesOfTheGalaxyNFT.deployed();
  const pepeNFTAddress = pepeNFT.address;

  // Deploy the PepesOfTheGalaxyBattle contract, passing in the addresses of the previously deployed contracts
  await deployer.deploy(PepesOfTheGalaxyBattle, pepeTokenAddress, pepeNFTAddress);
  const battleContract = await PepesOfTheGalaxyBattle.deployed();

  // Deploy the PepesOfTheGalaxyNFTStaking contract, passing in the addresses of the NFT and Token contracts
  await deployer.deploy(PepesOfTheGalaxyNFTStaking, pepeNFTAddress, pepeTokenAddress);
  const stakingContract = await PepesOfTheGalaxyNFTStaking.deployed();

  console.log(`PepesOfTheGalaxyToken is deployed at ${pepeTokenAddress}`);
  console.log(`PepesOfTheGalaxyNFT is deployed at ${pepeNFTAddress}`);
  console.log(`PepesOfTheGalaxyBattle is deployed at ${battleContract.address}`);
  console.log(`PepesOfTheGalaxyNFTStaking is deployed at ${stakingContract.address}`);
};
