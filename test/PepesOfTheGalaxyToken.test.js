const PepesOfTheGalaxyToken = artifacts.require("PepesOfTheGalaxyToken");
const { ethers } = require('ethers');

contract('PepesOfTheGalaxyToken', function (accounts) {
    let tokenInstance;

    const [owner, account1, account2, account3] = accounts;
    const tokenCap = ethers.utils.parseUnits('1000000');
    const totalSupply = ethers.utils.parseUnits('500000');

    beforeEach(async function () {
        tokenInstance = await PepesOfTheGalaxyToken.new(totalSupply, tokenCap, {from: owner});
    });

    describe('Token Metadata', function () {
        it('has a name', async function () {
            assert.equal(await tokenInstance.name(), 'Pepes of the Galaxy');
        });

        it('has a symbol', async function () {
            assert.equal(await tokenInstance.symbol(), 'PEPEOG');
        });
    });

    describe('Token Minting', function () {
        it('non-minter cannot mint tokens', async function () {
            await tokenInstance.setRule(true, owner, ethers.utils.parseUnits('10000'), ethers.utils.parseUnits('1'), {from: owner});
            try {
                await tokenInstance.mint(account1, ethers.utils.parseUnits('1000'), {from: account1});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'AccessControl: account ' + account1.toLowerCase() + ' is missing role ' + ethers.utils.id("MINTER_ROLE"));
            }
        });

        it('minter can mint tokens up to token cap', async function () {
            await tokenInstance.setRule(true, owner, ethers.utils.parseUnits('10000'), ethers.utils.parseUnits('1'), {from: owner});
            await tokenInstance.grantMinterRole(owner, {from: owner});

            let mintAmount = ethers.utils.parseUnits('1000');
            await tokenInstance.mint(owner, mintAmount, {from: owner});
            let balance = await tokenInstance.balanceOf(owner);
            let expectedBalance = totalSupply.add(mintAmount);
            assert.equal(balance.toString(), expectedBalance.toString(), 'Minted tokens not correctly received');
        
            try {
                await tokenInstance.mint(owner, tokenCap, {from: owner});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'Token cap exceeded');
            }
        });
    });

    describe('setRule', function () {
        it('only the owner can set rules', async function () {
            await tokenInstance.grantRole(ethers.utils.id("ADMIN_ROLE"), owner, {from: owner});
            try {
                await tokenInstance.setRule(true, owner, ethers.utils.parseUnits('10000'), ethers.utils.parseUnits('1'), {from: account1});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'AccessControl: caller is not the owner');
            }
        });
    });

    describe('transferOwnership', function () {
        it('only the owner can transfer ownership', async function () {
            try {
                await tokenInstance.transferOwnership(account1, {from: account2});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'Ownable: caller is not the owner');
            }
        });
    });

    describe('revokeMinterRole', function () {
        it('only the owner can revoke minter role', async function () {
            await tokenInstance.grantRole(ethers.utils.id("MINTER_ROLE"), account1, {from: owner});
            try {
                await tokenInstance.revokeRole(ethers.utils.id("MINTER_ROLE"), owner, {from: account1});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'AccessControl: account ' + account1.toLowerCase() + ' is missing role ' + ethers.utils.id("ADMIN_ROLE"));
            }
        });
    });

    describe('transferAdminRole', function () {
        it('only the owner can transfer admin role', async function () {
            try {
                await tokenInstance.transferRole(ethers.utils.id("ADMIN_ROLE"), account1, {from: account2});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'AccessControl: account ' + account2.toLowerCase() + ' is missing role ' + ethers.utils.id("ADMIN_ROLE"));
            }
        });
    });
});
