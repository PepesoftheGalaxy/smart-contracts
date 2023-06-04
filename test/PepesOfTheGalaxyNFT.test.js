const { assert, expect } = require('chai');
const { ethers } = require('hardhat');

describe("PepesOfTheGalaxyNFT Contract", function() {
    let PepesOfTheGalaxyNFT;
    let owner;
    let addr1;
    let addr2;
    let addrs;
  
    beforeEach(async function () {
      [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  
      const PepeContract = await ethers.getContractFactory("PepesOfTheGalaxyNFT");
      PepesOfTheGalaxyNFT = await PepeContract.deploy(owner.address); 
      await PepesOfTheGalaxyNFT.deployed();
    });
  
    describe("Transactions", function() {
        it("Should mint a new Pepe", async function () {
            const mintPepeTx = await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
            
            // Wait for the transaction to be mined and get the receipt
            const receipt = await mintPepeTx.wait();
        
            // Extract the event logs
            const event = receipt.events.filter((x) => x.event == "Transfer")[0];
        
            // The token ID should be the last parameter of the event
            const newPepeId = event.args[2].toString();
        
            assert.equal(newPepeId, "1");
        });    
        
        it("Should fail if not enough MATIC is sent", async function () {
          await expect(PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.01")})).to.be.revertedWith("Minting a Pepe costs 50 MATIC");
      });      

      it("Should emit the correct NewPepe event when a new Pepe is minted", async function () {
        await expect(PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")})).to.emit(PepesOfTheGalaxyNFT, 'NewPepe').withArgs(1, addr2.address, "https://tokenURI.com");
      });
      
      it("Should correctly store token metadata", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        const pepeAttributes = await PepesOfTheGalaxyNFT.getPepeAttributes(1);
        assert.equal(pepeAttributes.appearance.toString(), "5");
        assert.equal(pepeAttributes.accessories.toString(), "3");
      });
  
      it("Should return the attributes of a Pepe", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        const pepeAttributes = await PepesOfTheGalaxyNFT.getPepeAttributes(1);
        assert.equal(pepeAttributes.appearance.toString(), "5");
        assert.equal(pepeAttributes.accessories.toString(), "3");
        assert.equal(pepeAttributes.experience.toString(), "0");
      });

      it("Should correctly update experience", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        await PepesOfTheGalaxyNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address);
        await PepesOfTheGalaxyNFT.connect(addr1).addExperience(1, 10);
        const pepeAttributes = await PepesOfTheGalaxyNFT.getPepeAttributes(1);
        assert.equal(pepeAttributes.experience.toString(), "10");
      });
      
      it("Should fail when trying to access a non-existent token", async function () {
        await expect(PepesOfTheGalaxyNFT.getPepeAttributes(100)).to.be.revertedWith("Pepe does not exist");
      });        

      it("Should correctly assign roles", async function () {
        await PepesOfTheGalaxyNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address);
        assert.isTrue(await PepesOfTheGalaxyNFT.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address));
      });  
    
      it("Should fail if someone without the EXPERIENCE_UPDATER_ROLE tries to update experience", async function () {
        await expect(PepesOfTheGalaxyNFT.connect(addr2).addExperience(1, 10)).to.be.revertedWith("Caller is not allowed to update experience");
      });

      it("Should correctly mint multiple Pepes", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 7, 2, {value: ethers.utils.parseEther("0.05")});
        const pepe1Attributes = await PepesOfTheGalaxyNFT.getPepeAttributes(1);
        const pepe2Attributes = await PepesOfTheGalaxyNFT.getPepeAttributes(2);
        assert.equal(pepe1Attributes.appearance.toString(), "5");
        assert.equal(pepe2Attributes.appearance.toString(), "7");
      });    
  
      it("Should allow an address with the EXPERIENCE_UPDATER_ROLE to update experience", async function () {
        await PepesOfTheGalaxyNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address);
        await expect(PepesOfTheGalaxyNFT.connect(addr1).addExperience(1, 10)).to.emit(PepesOfTheGalaxyNFT, 'ExperienceUpdated');
      });
      it("Should correctly emit NewPepe event with appropriate arguments", async function () {
        const mintTx = await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        await expect(mintTx)
            .to.emit(PepesOfTheGalaxyNFT, 'NewPepe')
            .withArgs(1, addr2.address, "https://tokenURI.com");
      });
    
    it("Should correctly emit ExperienceUpdated event with appropriate arguments", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        await PepesOfTheGalaxyNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address);
        const updateExperienceTx = await PepesOfTheGalaxyNFT.connect(addr1).addExperience(1, 10);
        await expect(updateExperienceTx)
            .to.emit(PepesOfTheGalaxyNFT, 'ExperienceUpdated')
            .withArgs(1, 10);
    });
    

      });
      describe("Deployment", function() {
        it("Should set up the ADMIN_ROLE properly", async function () {
            // Check if the `owner` address has the DEFAULT_ADMIN_ROLE
            const isAdmin = await PepesOfTheGalaxyNFT.hasRole(
                await PepesOfTheGalaxyNFT.DEFAULT_ADMIN_ROLE(),
                owner.address
            );
            assert.isTrue(isAdmin);
        });
    });
     
    
  });
  