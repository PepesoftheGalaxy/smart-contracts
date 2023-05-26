const { BN, expectRevert } = require('@openzeppelin/test-helpers');
const PepeGalaxyToken = artifacts.require('PepeGalaxyToken');

contract('PepeGalaxyToken', function (accounts) {
  const [ owner, recipient, anotherAccount ] = accounts;

  beforeEach(async function () {
    // Deploy a new instance of PepeGalaxyToken before each test
    this.token = await PepeGalaxyToken.new(new BN('420000000000069'), { from: owner });
  });

  it('has a name and a symbol', async function () {
    // Check if the token has the correct name and symbol
    assert.equal(await this.token.name(), 'Pepes of the Galaxy'); // Verify the name
    assert.equal(await this.token.symbol(), 'PEPEG'); // Verify the symbol
  });

  it('mints tokens to the owner', async function () {
    // Check if the total supply is equal to the owner's balance
    const totalSupply = await this.token.totalSupply();
    const ownerBalance = await this.token.balanceOf(owner);
    assert.equal(totalSupply.toString(), ownerBalance.toString());
  });

  it('cannot transfer tokens before Uniswap pair is set', async function () {
    // Attempt to transfer tokens before setting the Uniswap pair and expect it to revert
    await expectRevert(
      this.token.transfer(recipient, new BN(1), { from: owner }),
      'trading is not started'
    );
  });

  it('allows the owner to set the Uniswap pair', async function () {
    // Set the Uniswap pair and verify if it was set correctly
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    assert.equal(await this.token.uniswapV2Pair(), recipient);
  });

  it('allows transfer of tokens after Uniswap pair is set', async function () {
    // Set the Uniswap pair, transfer tokens, and check recipient's balance
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(1), { from: owner });
    const recipientBalance = await this.token.balanceOf(recipient);
    assert.equal(recipientBalance.toString(), '1');
  });

  it('allows token holders to burn their tokens', async function () {
    // Set the Uniswap pair, transfer tokens to the recipient, burn tokens, and check recipient's balance
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(1), { from: owner });
    await this.token.burn(new BN(1), { from: recipient });
    const recipientBalance = await this.token.balanceOf(recipient);
    assert.equal(recipientBalance.toString(), '0');
  });

  it('has the correct initial total supply', async function () {
    // Check if the initial total supply matches the expected value
    const totalSupply = await this.token.totalSupply();
    assert.equal(totalSupply.toString(), '420000000000069');
  });

  it('updates balances after transfer', async function () {
    // Set the Uniswap pair, transfer tokens, and check owner and recipient balances
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(1), { from: owner });
    const totalSupply = await this.token.totalSupply();
    const ownerBalance = await this.token.balanceOf(owner);
    const recipientBalance = await this.token.balanceOf(recipient);
    assert.equal(ownerBalance.toString(), (totalSupply.sub(new BN(1))).toString());
  });

  it('reverts when non-owner tries to set trading rules', async function () {
    // Attempt to set trading rules from an account that is not the owner and expect it to revert
    await expectRevert(
      this.token.setRule(false, recipient, new BN(1), new BN(1), { from: anotherAccount }),
      'Ownable: caller is not the owner'
    );
  });

  it('reverts when trying to transfer more tokens than owned', async function () {
    // Set the Uniswap pair
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    // Attempt to transfer more tokens than the owner holds and expect it to revert
    await expectRevert(
      this.token.transfer(recipient, new BN('420000000000070'), { from: owner }),
      'ERC20: transfer amount exceeds balance'
    );
  });

  it('reverts when trying to burn more tokens than owned', async function () {
    // Set the Uniswap pair and transfer some tokens
    await this.token.setRule(false, recipient, new BN(1), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(1), { from: owner });
    // Attempt to burn more tokens than the recipient holds and expect it to revert
    await expectRevert(
      this.token.burn(new BN(2), { from: recipient }),
      'ERC20: burn amount exceeds balance'
    );
  });

  it('reverts when trying to transfer tokens that would violate the holding limits', async function () {
    // Set the Uniswap pair and the trading limits
    await this.token.setRule(true, recipient, new BN(5), new BN(1), { from: owner });
    // Attempt to transfer a token amount that would cause the recipient's balance to exceed the maximum limit
    await expectRevert(
      this.token.transfer(recipient, new BN(6), { from: owner }),
      'Forbid'
    );
  });

  it('allows transfer of tokens above maximum limit when trading limit is not active', async function () {
    // Set the Uniswap pair and the trading limits, but do not activate the limit
    await this.token.setRule(false, recipient, new BN(5), new BN(1), { from: owner });
    // Transfer a token amount that would cause the recipient's balance to exceed the maximum limit
    await this.token.transfer(recipient, new BN(6), { from: owner });
    const recipientBalance = await this.token.balanceOf(recipient);
    assert.equal(recipientBalance.toString(), '6');
  });

  it('does not allow transfer of tokens when Uniswap pair is not set even if trading limit is active', async function () {
    // Activate the trading limit but do not set the Uniswap pair
    await this.token.setRule(true, address(0), new BN(5), new BN(1), { from: owner });
    // Attempt to transfer tokens and expect it to revert
    await expectRevert(
      this.token.transfer(recipient, new BN(1), { from: owner }),
      'trading is not started'
    );
  });

  it('reverts when trying to transfer tokens that would violate the minimum holding limit', async function () {
    // Set the Uniswap pair and the trading limits
    await this.token.setRule(true, recipient, new BN(5), new BN(3), { from: owner });
    // Attempt to transfer a token amount that would cause the recipient's balance to be less than the minimum limit
    await this.token.transfer(recipient, new BN(4), { from: owner });
    await expectRevert(
      this.token.transfer(anotherAccount, new BN(2), { from: recipient }),
      'Forbid'
    );
  });

  it('allows zero token transfer', async function () {
    await this.token.setRule(false, recipient, new BN(10), new BN(1), { from: owner });
    const initialOwnerBalance = await this.token.balanceOf(owner);
    await this.token.transfer(recipient, new BN(0), { from: owner });
    const finalOwnerBalance = await this.token.balanceOf(owner);
    assert.equal(initialOwnerBalance.toString(), finalOwnerBalance.toString());
  });

  it('allows self token transfer', async function () {
    await this.token.setRule(false, owner, new BN(10), new BN(1), { from: owner });
    const initialOwnerBalance = await this.token.balanceOf(owner);
    await this.token.transfer(owner, new BN(1), { from: owner });
    const finalOwnerBalance = await this.token.balanceOf(owner);
    assert.equal(initialOwnerBalance.toString(), finalOwnerBalance.toString());
  });

  it('allows transfer when recipient balance equals exactly to max or min holding amount', async function () {
    await this.token.setRule(true, recipient, new BN(5), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(5), { from: owner }); // balance equal to maxHoldingAmount
    const recipientBalanceMax = await this.token.balanceOf(recipient);
    assert.equal(recipientBalanceMax.toString(), '5');

    await this.token.setRule(true, anotherAccount, new BN(5), new BN(1), { from: owner });
    await this.token.transfer(anotherAccount, new BN(1), { from: owner }); // balance equal to minHoldingAmount
    const anotherAccountBalanceMin = await this.token.balanceOf(anotherAccount);
    assert.equal(anotherAccountBalanceMin.toString(), '1');
  });

  it('allows burning zero tokens', async function () {
    await this.token.setRule(false, recipient, new BN(10), new BN(1), { from: owner });
    await this.token.transfer(recipient, new BN(5), { from: owner });
    await this.token.burn(new BN(0), { from: recipient });
    const recipientBalance = await this.token.balanceOf(recipient);
    assert.equal(recipientBalance.toString(), '5');
  });
});
