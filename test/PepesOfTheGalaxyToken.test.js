const { expect } = require('chai');
const { ethers } = require('truffle-ethers');

const PepesOfTheGalaxyToken = artifacts.require('PepesOfTheGalaxyToken');

contract('PepesOfTheGalaxyToken', function (accounts) {
    const [ owner, other, uniswapV2Pair ] = accounts;

    beforeEach(async function () {
        this.token = await PepesOfTheGalaxyToken.new(100000, { from: owner });
    });

    describe('constructor', function () {
        it('should assign the total supply of tokens to the owner', async function () {
            const ownerBalance = await this.token.balanceOf(owner);
            expect(ownerBalance.toString()).to.equal('100000');
        });
    });

    describe('setRule', function () {
        it('should set trading rules', async function () {
            await this.token.setRule(true, uniswapV2Pair, 5000, 1000, { from: owner });

            const limited = await this.token.limited();
            const maxHoldingAmount = await this.token.maxHoldingAmount();
            const minHoldingAmount = await this.token.minHoldingAmount();
            const pair = await this.token.uniswapV2Pair();

            expect(limited).to.equal(true);
            expect(maxHoldingAmount.toString()).to.equal('5000');
            expect(minHoldingAmount.toString()).to.equal('1000');
            expect(pair).to.equal(uniswapV2Pair);
        });
    });

    describe('_beforeTokenTransfer', function () {
        it('should not allow transfers if trading is not started', async function () {
            await expect(
                this.token.transfer(other, 100, { from: owner })
            ).to.be.revertedWith('trading is not started');
        });

        it('should check the holding restrictions', async function () {
            await this.token.setRule(true, uniswapV2Pair, 5000, 1000, { from: owner });
            await this.token.transfer(uniswapV2Pair, 5000, { from: owner });
            
            await expect(
                this.token.transfer(other, 6000, { from: uniswapV2Pair })
            ).to.be.revertedWith('Forbid');
        });
    });

    describe('transferOwnership', function () {
        it('should transfer ownership', async function () {
            await this.token.transferOwnership(other, { from: owner });
            const newOwner = await this.token.owner();
            expect(newOwner).to.equal(other);
        });

        it('should not allow zero address to be owner', async function () {
            await expect(
                this.token.transferOwnership(ethers.constants.AddressZero, { from: owner })
            ).to.be.revertedWith('Invalid new owner');
        });
    });
    describe('setRule', function () {
        it('should not allow non-owners to set rules', async function () {
            await expect(
                this.token.setRule(true, uniswapV2Pair, 5000, 1000, { from: other })
            ).to.be.revertedWith('Ownable: caller is not the owner');
        });
    });
    
    describe('_beforeTokenTransfer', function () {
        it('should not check holding restrictions when from is not uniswapV2Pair', async function () {
            await this.token.setRule(true, uniswapV2Pair, 5000, 1000, { from: owner });
            await this.token.transfer(other, 100, { from: owner });
    
            const otherBalance = await this.token.balanceOf(other);
            expect(otherBalance.toString()).to.equal('100');
        });
    
        it('should allow transfer when holding is exactly at max or min limit', async function () {
            await this.token.setRule(true, uniswapV2Pair, 5000, 1000, { from: owner });
            await this.token.transfer(uniswapV2Pair, 5000, { from: owner });
    
            await expect(
                this.token.transfer(other, 5000, { from: uniswapV2Pair })
            ).to.be.fulfilled;
    
            await expect(
                this.token.transfer(uniswapV2Pair, 4000, { from: other })
            ).to.be.fulfilled;
    
            await expect(
                this.token.transfer(other, 1000, { from: uniswapV2Pair })
            ).to.be.fulfilled;
        });
    });
    
    describe('transferOwnership', function () {
        it('should not allow non-owners to transfer ownership', async function () {
            await expect(
                this.token.transferOwnership(other, { from: other })
            ).to.be.revertedWith('Ownable: caller is not the owner');
        });
    });    
});
