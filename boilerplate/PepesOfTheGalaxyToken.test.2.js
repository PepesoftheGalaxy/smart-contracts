const PepesOfTheGalaxyToken = artifacts.require("PepesOfTheGalaxyToken");
const { ethers } = require('ethers');

contract('PepesOfTheGalaxyToken', function (accounts) {
    let tokenInstance;

    const [owner, account1, account2, account3] = accounts;
    const totalSupply = ethers.utils.parseUnits('500000');

    beforeEach(async function () {
        tokenInstance = await PepesOfTheGalaxyToken.new(totalSupply, {from: owner});
    });

    describe('Token Metadata', function () {
        it('has a name', async function () {
            assert.equal(await tokenInstance.name(), 'Pepes of the Galaxy');
        });

        it('has a symbol', async function () {
            assert.equal(await tokenInstance.symbol(), 'PEPEOG');
        });
    });

    describe('setRule', function () {
        it('only the owner can set rules', async function () {
            try {
                await tokenInstance.setRule(true, owner, ethers.utils.parseUnits('10000'), ethers.utils.parseUnits('1'), {from: account1});
                assert.fail('Should have thrown an error');
            } catch (err) {
                assert.include(err.message, 'Ownable: caller is not the owner');
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
});
