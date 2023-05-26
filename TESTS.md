# PepeGalaxyToken Tests Documentation

This document describes tests for the `PepeGalaxyToken` smart contract using the [Truffle](https://www.trufflesuite.com/) testing framework. The contract is an ERC20 token with additional features such as burning tokens and setting trading rules.

## Tests

1. **Token properties test:** This test checks if the token has the correct name and symbol.

2. **Initial minting test:** This test verifies that all the tokens are minted to the contract owner upon deployment.

3. **Transfer restriction test:** This test ensures that tokens cannot be transferred before setting the Uniswap pair.

4. **Uniswap pair setting test:** This test verifies that the contract owner can set the Uniswap pair.

5. **Transfer post-Uniswap pair test:** This test checks that tokens can be transferred after setting the Uniswap pair.

6. **Token burning test:** This test verifies that token holders can burn their tokens.

7. **Initial total supply test:** This test checks if the initial total supply is correct.

8. **Balance update test:** This test verifies that balances are updated correctly after a transfer.

9. **Ownership restriction test:** This test ensures that only the contract owner can set trading rules.

10. **Transfer limit test:** This test checks that a user cannot transfer more tokens than they own.

11. **Burn limit test:** This test verifies that a user cannot burn more tokens than they own.

12. **Holding limit test:** This test ensures that transfers that would violate holding limits are not allowed.

13. **Trading limit inactivity test:** This test verifies that tokens can be transferred above the maximum limit when trading limit is not active.

14. **Trading restriction test:** This test checks that tokens cannot be transferred when the Uniswap pair is not set even if the trading limit is active.

15. **Minimum holding limit test:** This test ensures that transfers that would violate the minimum holding limit are not allowed.

16. **Zero token transfer test:** This test checks that a zero token transfer is allowed.

17. **Self token transfer test:** This test verifies that an account can transfer tokens to itself.

18. **Exact holding limit test:** This test checks that a transfer is allowed when the recipient's balance equals exactly to the maximum or minimum holding amount.

19. **Zero token burning test:** This test verifies that burning zero tokens is allowed.

## Running the Tests

To run the tests, follow these steps:

1. Clone the repository: `git clone <repository url>`

2. Navigate to the project folder: `cd <project folder>`

3. Install the dependencies: `npm install`

4. Run the tests: `truffle test`

The tests should now execute and display the results on the console.