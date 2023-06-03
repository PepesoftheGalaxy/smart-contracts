require('dotenv').config();.

const { MNEMONIC, PROJECT_ID } = process.env;

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {

  networks: {
   development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
     },
     mumbai: {
      provider: () => new HDWalletProvider(MNEMONIC, `https://rpc.ankr.com/polygon_mumbai`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bnbtestnet: {
      provider: () => new HDWalletProvider(MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545/`),
      network_id: 97,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bnbmainnet: {
      provider: () => new HDWalletProvider(MNEMONIC, `https://bsc-dataseed1.binance.org/`),
      network_id: 56,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  },

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },
  // Configure your compilers
  compilers: {
  solc: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200  // Optimize for how many times you expect the contract to be called
      }
    }
  }
},
};
