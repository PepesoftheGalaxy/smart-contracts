const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PepesOfTheGalaxyNFTStaking", function () {
    let PepesOfTheGalaxyNFT;
    let PepesOfTheGalaxyToken;
    let PepesOfTheGalaxyNFTStaking;
    let pepeNFT;
    let pepeToken;
    let stakingContract;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        // Get contract factories
        PepesOfTheGalaxyNFT = await ethers.getContractFactory("PepesOfTheGalaxyNFT");
        PepesOfTheGalaxyToken = await ethers.getContractFactory("PepesOfTheGalaxyToken");
        PepesOfTheGalaxyNFTStaking = await ethers.getContractFactory("PepesOfTheGalaxyNFTStaking");

        // Get signers
        [owner, addr1, addr2, _] = await ethers.getSigners();

        // Deploy contracts
        const gnosisMultisigWallet = owner.address; // Please replace with the actual address of the multisig wallet
        pepeNFT = await PepesOfTheGalaxyNFT.deploy(gnosisMultisigWallet);
        pepeToken = await PepesOfTheGalaxyToken.deploy(ethers.utils.parseEther("8880000000"));
        stakingContract = await PepesOfTheGalaxyNFTStaking.deploy(pepeNFT.address, pepeToken.address);
        await pepeToken.setRule(true, addr1.address, ethers.utils.parseEther("1000"), ethers.utils.parseEther("500"));


        // Mint tokens and NFTs
        await pepeToken.transfer(addr1.address, ethers.utils.parseEther("1000000"));
        await pepeToken.transfer(addr2.address, ethers.utils.parseEther("1000000"));
        await pepeToken.transfer(stakingContract.address, ethers.utils.parseEther("1000000000"));
        await pepeNFT.connect(addr1).mintPepe(addr1.address, "uri1", 1, 1, { value: ethers.utils.parseEther("0.05") });
        await pepeNFT.connect(addr2).mintPepe(addr2.address, "uri2", 2, 2, { value: ethers.utils.parseEther("0.05") });
    });

    it("Should allow users to stake their NFTs", async function () {
        await pepeNFT.connect(addr1).approve(stakingContract.address, 1);
        await stakingContract.connect(addr1).stakeNFT(1);
        expect(await pepeNFT.ownerOf(1)).to.equal(stakingContract.address);
    });

    it("Should not allow users to stake NFTs they do not own", async function () {
        await expect(stakingContract.connect(addr1).stakeNFT(2)).to.be.revertedWith("Not owner of this NFT");
    });

    it("Should not allow users to stake more than one NFT", async function () {
      await pepeNFT.connect(addr1).approve(stakingContract.address, 1);
      await stakingContract.connect(addr1).stakeNFT(1);
  
      // Mint a new NFT with a different ID
      await pepeNFT.connect(addr1).mintPepe(addr1.address, "uri3", 3, 1, { value: ethers.utils.parseEther("0.05") });
      await pepeNFT.connect(addr1).approve(stakingContract.address, 3);
  
      await expect(stakingContract.connect(addr1).stakeNFT(3)).to.be.revertedWith("Already staking an NFT");
  });  

    it("Should allow users to withdraw their staked NFTs after the minimum staking time", async function () {
        // Set minimum staking time to 0 for the purpose of this test
        await stakingContract.setMinStakingTime(0);

        await pepeNFT.connect(addr1).approve(stakingContract.address, 1);
        await stakingContract.connect(addr1).stakeNFT(1);

        // Skip ahead in time (use ethers.provider.send("evm_increaseTime", [timeInSeconds]) in production code)
        //await ethers.provider.send("evm_increaseTime", [60 * 60]);

        await stakingContract.connect(addr1).withdrawNFT(1);
        expect(await pepeNFT.ownerOf(1)).to.equal(addr1.address);
    });

    it("Should not allow users to withdraw their staked NFTs before the minimum staking time", async function () {
        // Set minimum staking time to 1 hour for the purpose of this test
        await stakingContract.setMinStakingTime(60 * 60);

        await pepeNFT.connect(addr1).approve(stakingContract.address, 1);
        await stakingContract.connect(addr1).stakeNFT(1);

        await expect(stakingContract.connect(addr1).withdrawNFT(1)).to.be.revertedWith("Minimum staking time not reached");
    });
});
