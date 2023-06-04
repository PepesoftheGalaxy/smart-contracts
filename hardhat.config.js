require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan"); // plugin for contract verification
require('dotenv').config();

const { MNEMONIC, INFURA_PROJECT_ID, POLYGONSCANAPIKEY } = process.env;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: { mnemonic: MNEMONIC },
    },
    bnbtestnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
      accounts: { mnemonic: MNEMONIC },
    },
    bnbmainnet: {
      url: `https://bsc-dataseed1.binance.org/`,
      accounts: { mnemonic: MNEMONIC },
    }
  },
  etherscan: {
    apiKey: POLYGONSCANAPIKEY
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    artifacts: './build/contracts'
  },
};
