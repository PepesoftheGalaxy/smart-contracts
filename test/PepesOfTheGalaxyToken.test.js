const { assert, expect } = require('chai');
const { ethers } = require('hardhat');

describe('PepesOfTheGalaxyToken', function () {
    let owner;
    let other;
    let another;
    let uniswapV2Pair;
    let PepesOfTheGalaxyToken;
    let token;

    beforeEach(async function () {
        [owner, other, uniswapV2Pair, another, ...rest] = await ethers.getSigners();
        PepesOfTheGalaxyToken = await ethers.getContractFactory('PepesOfTheGalaxyToken');
        token = await PepesOfTheGalaxyToken.deploy(8880000000);
        await token.deployed();
    });

    describe('constructor', function () {
        it('should assign the total supply of tokens to the owner', async function () {
            const ownerBalance = await token.balanceOf(owner.address);
            expect(ownerBalance.toString()).to.equal('8880000000');
        });
    });

    describe('setRule', function () {
        it('should set trading rules', async function () {
            await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);

            const limited = await token.limited();
            const maxHoldingAmount = await token.maxHoldingAmount();
            const minHoldingAmount = await token.minHoldingAmount();
            const pair = await token.uniswapV2Pair();

            expect(limited).to.equal(true);
            expect(maxHoldingAmount.toString()).to.equal('5000');
            expect(minHoldingAmount.toString()).to.equal('1000');
            expect(pair).to.equal(uniswapV2Pair.address);
        });
    });

    describe('_beforeTokenTransfer', function () {
        it('should not allow transfers if trading is not started', async function () {
            // Transfer some tokens to `other` account
            await token.connect(owner).transfer(other.address, 200);
            try {
                // Try to transfer from `other` to `another` account
                await token.connect(other).transfer(another.address, 100);
                assert.fail("Expected transaction to be reverted");
            } catch (e) {
                assert.include(e.message, 'trading is not started');
            }

            // Start trading by setting trading rules
             await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);

             // Try to transfer again after trading is started
            await token.connect(other).transfer(another.address, 100);

        });        

        it('should check the holding restrictions', async function () {
            await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);
            await token.connect(owner).transfer(uniswapV2Pair.address, 5000);
            
            await expect(
                token.connect(uniswapV2Pair).transfer(other.address, 6000)
            ).to.be.revertedWith('Forbid');
        });
    });

    describe('_beforeTokenTransfer', function () {
        it('should allow transfers when trading is started', async function () {
            // Start trading by setting trading rules
            await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);
    
            // Transfer some tokens to `other` account
            await token.connect(owner).transfer(other.address, 200);
    
            // Try to transfer from `other` to `another` account
            await token.connect(other).transfer(another.address, 100);
    
            // Verify the balances of `other` and `another` accounts
            const otherBalance = await token.balanceOf(other.address);
            const anotherBalance = await token.balanceOf(another.address);
            expect(otherBalance.toString()).to.equal('100');
            expect(anotherBalance.toString()).to.equal('100');
        });
    });    

    describe('transferOwnership', function () {
        it('should transfer ownership', async function () {
            await token.connect(owner).transferOwnership(other.address);
            const newOwner = await token.owner();
            expect(newOwner).to.equal(other.address);
        });

        it('should not allow zero address to be owner', async function () {
            await expect(
                token.connect(owner).transferOwnership(ethers.constants.AddressZero)
            ).to.be.revertedWith('Invalid new owner');
        });
    });

    describe('setRule', function () {
        it('should not allow non-owners to set rules', async function () {
            await expect(
                token.connect(other).setRule(true, uniswapV2Pair.address, 5000, 1000)
            ).to.be.revertedWith('Ownable: caller is not the owner');
        });
    });
    
    describe('_beforeTokenTransfer', function () {
        it('should not check holding restrictions when from is not uniswapV2Pair', async function () {
            await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);
            await token.connect(owner).transfer(other.address, 100);
    
            const otherBalance = await token.balanceOf(other.address);
            expect(otherBalance.toString()).to.equal('100');
        });
    
        it('should allow transfer when holding is exactly at max or min limit', async function () {
            await token.connect(owner).setRule(true, uniswapV2Pair.address, 5000, 1000);
            await token.connect(owner).transfer(uniswapV2Pair.address, 5000);
    
            try {
                await token.connect(uniswapV2Pair).transfer(other.address, 5000);
                await token.connect(other).transfer(uniswapV2Pair.address, 4000);
                await token.connect(uniswapV2Pair).transfer(other.address, 1000);
            } catch (e) {
                assert.fail("Expected transactions to succeed");
            }
        });
    });
    describe('transferOwnership', function () {
        it('should not allow non-owners to transfer ownership', async function () {
            await expect(
                token.connect(other).transferOwnership(other.address)
            ).to.be.revertedWith('Ownable: caller is not the owner');
        });
    });    
});