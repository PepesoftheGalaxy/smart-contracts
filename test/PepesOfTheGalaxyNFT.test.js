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
      PepesOfTheGalaxyNFT = await PepeContract.deploy(addr1.address); // Assume addr1 is the gnosisMultisigWallet address
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
  
      it("Should return the attributes of a Pepe", async function () {
        await PepesOfTheGalaxyNFT.connect(addr2).mintPepe(addr2.address, "https://tokenURI.com", 5, 3, {value: ethers.utils.parseEther("0.05")});
        const pepeAttributes = await PepesOfTheGalaxyNFT.getPepeAttributes(1);
        assert.equal(pepeAttributes.appearance.toString(), "5");
        assert.equal(pepeAttributes.accessories.toString(), "3");
        assert.equal(pepeAttributes.experience.toString(), "0");
      });
    
      it("Should fail if someone without the EXPERIENCE_UPDATER_ROLE tries to update experience", async function () {
        await expect(PepesOfTheGalaxyNFT.connect(addr2).addExperience(1, 10)).to.be.revertedWith("Caller is not allowed to update experience");
      });
  
      it("Should allow an address with the EXPERIENCE_UPDATER_ROLE to update experience", async function () {
        await PepesOfTheGalaxyNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("EXPERIENCE_UPDATER_ROLE")), addr1.address);
        await expect(PepesOfTheGalaxyNFT.connect(addr1).addExperience(1, 10)).to.emit(PepesOfTheGalaxyNFT, 'ExperienceUpdated');
      });

      });
  });
  