const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { waffle } = require("hardhat");

describe("PepesOfTheGalaxyBattle", function () {
  let PepesOfTheGalaxyBattle;
  let battleContract;
  let pepeNFT;
  let pepeToken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // Here deploy your PepesOfTheGalaxyNFT and PepesOfTheGalaxyToken contracts
    let PepesOfTheGalaxyNFT = await ethers.getContractFactory("PepesOfTheGalaxyNFT");
    let PepesOfTheGalaxyToken = await ethers.getContractFactory("PepesOfTheGalaxyToken");

    const initialSupply = ethers.utils.parseEther("8880000000"); // Initial total supply of tokens
    const gnosisMultisigWallet = "0x323bfFC91B1bF1fEd989af025732eeFfd262bb9e"; // Replace with the actual address of the multisig wallet

    pepeToken = await PepesOfTheGalaxyToken.deploy(initialSupply);
    pepeNFT = await PepesOfTheGalaxyNFT.deploy(gnosisMultisigWallet);

    PepesOfTheGalaxyBattle = await ethers.getContractFactory("PepesOfTheGalaxyBattle");
    [owner, addr1, addr2, _] = await ethers.getSigners();
    battleContract = await PepesOfTheGalaxyBattle.deploy(pepeNFT.address, pepeToken.address);

    let Wallet = ethers.Wallet;
    let randomWallet = Wallet.createRandom();
    let uniswapV2Pair = randomWallet.address; // This is a random Ethereum address
    let maxHoldingAmount = ethers.utils.parseEther("1000000"); // Set your desired max holding amount
    let minHoldingAmount = ethers.utils.parseEther("1"); // Set your desired min holding amount
    let limited = true; // Set this to true or false as per your requirements
    await pepeToken.setRule(limited, uniswapV2Pair, maxHoldingAmount, minHoldingAmount);
    const transferAmount = ethers.utils.parseEther("1000000");
    await pepeToken.transfer(addr1.address, transferAmount);
    await pepeToken.transfer(addr2.address, transferAmount);
    await owner.sendTransaction({ to: addr1.address, value: ethers.utils.parseEther("1") });
    await owner.sendTransaction({ to: addr2.address, value: ethers.utils.parseEther("1") });
    await pepeNFT.connect(addr1).mintPepe(addr1.address, "uri1", 5, 5, { value: ethers.utils.parseEther("0.05") });
    await pepeNFT.connect(addr2).mintPepe(addr2.address, "uri2", 15, 25, { value: ethers.utils.parseEther("0.05") });
    await pepeNFT.grantRole(pepeNFT.EXPERIENCE_UPDATER_ROLE(), battleContract.address);

    // Approve a higher allowance for the battle contract
    const higherAllowance = ethers.utils.parseEther("1000");
    await pepeToken.connect(addr1).approve(battleContract.address, higherAllowance);
  });

  it("Should add a stake", async function () {
    await pepeToken.connect(addr1).approve(battleContract.address, ethers.utils.parseEther("10"));
    await battleContract.connect(addr1).stake(1, ethers.utils.parseEther("10"));
    let battleRequest = await battleContract.battleRequests(0);
    console.log("Battle Request:", battleRequest);
    expect(battleRequest[0]).to.equal(1); // pepeId
    expect(battleRequest[1]).to.equal(ethers.utils.parseEther("10")); // amount
    expect(battleRequest[2]).to.equal(addr1.address); // player
  });

  it("Should not start a battle with fewer than two stakes", async function () {
    await expect(battleContract.connect(owner).battle()).to.be.revertedWith("Not enough players");
  });  

  it("Should revert when staking more tokens than the player's balance", async function () {
    // Attempt to stake an amount greater than the player's token balance
    const tooLargeStake = ethers.utils.parseEther("1000000000000000000001"); // Assume this is larger than the player's balance

    // Expect the transaction to be reverted with a specific error message (replace "Error message" with the actual error message)
    await expect(battleContract.connect(addr1).stake(1, tooLargeStake)).to.be.revertedWith("Insufficient balance");
  });

  it("Should transfer all staked tokens to the winner", async function () {
    const stakeAmount1 = ethers.utils.parseEther("1500");
    const stakeAmount2 = ethers.utils.parseEther("20");
  
    // Check initial balances before staking
    const initialBalanceBeforeStaking1 = await pepeToken.balanceOf(addr1.address);
    const initialBalanceBeforeStaking2 = await pepeToken.balanceOf(addr2.address);
    
    // Calculate the sum of starting balances
    const totalInitialBalance = initialBalanceBeforeStaking1.add(initialBalanceBeforeStaking2);
  
    console.log(`Initial balance of addr1 before staking: ${ethers.utils.formatEther(initialBalanceBeforeStaking1)}`);
    console.log(`Initial balance of addr2 before staking: ${ethers.utils.formatEther(initialBalanceBeforeStaking2)}`);
  
    await pepeToken.connect(addr1).approve(battleContract.address, stakeAmount1);
    await battleContract.connect(addr1).stake(1, stakeAmount1);
  
    // Log the contract balance after the first staking
    let contractBalance = await pepeToken.balanceOf(battleContract.address);
    console.log(`Contract balance after first staking: ${ethers.utils.formatEther(contractBalance)}`);
  
    await pepeToken.connect(addr2).approve(battleContract.address, stakeAmount2);
    await battleContract.connect(addr2).stake(2, stakeAmount2);
  
    // Log the contract balance after the second staking
    contractBalance = await pepeToken.balanceOf(battleContract.address);
    console.log(`Contract balance after second staking: ${ethers.utils.formatEther(contractBalance)}`);
  
    const totalStake = stakeAmount1.add(stakeAmount2);
  
    // Assuming battle happens automatically after 2 stakes, otherwise trigger it manually
    // await battleContract.battle();
  
    /// ...
  
    // Calculate final balances
    const finalBalance1 = await pepeToken.balanceOf(addr1.address);
    const finalBalance2 = await pepeToken.balanceOf(addr2.address);
  
    console.log(`Final balance of addr1: ${ethers.utils.formatEther(finalBalance1)}`);
    console.log(`Final balance of addr2: ${ethers.utils.formatEther(finalBalance2)}`);
  
    // Check if the winner got all the staked tokens
    if (finalBalance1.gt(initialBalanceBeforeStaking1)) {
      console.log(`Winner is addr1 with pepeId: 1`);
      expect(finalBalance1).to.equal(initialBalanceBeforeStaking1.add(stakeAmount2)); // The winner (addr1) balance increased by the stake amount of addr2
    } else {
      console.log(`Winner is addr2 with pepeId: 2`);
      expect(finalBalance2).to.equal(initialBalanceBeforeStaking2.add(stakeAmount1)); // The winner (addr2) balance increased by the stake amount of addr1
    }
  
    // Calculate the sum of final balances
    const totalFinalBalance = finalBalance1.add(finalBalance2);
  
    // Check if the sum of the starting balances equals the sum of the ending balances
    expect(totalInitialBalance).to.equal(totalFinalBalance);
  
    // Log the contract balance after the battle
    contractBalance = await pepeToken.balanceOf(battleContract.address);
    console.log(`Contract balance after battle: ${ethers.utils.formatEther(contractBalance)}`);
  
    // Assert that contract balance is zero after the battle
    expect(contractBalance).to.equal(0);
  });
  
  





});
