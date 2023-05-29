const PepesOfTheGalaxyToken = artifacts.require("PepesOfTheGalaxyToken");

module.exports = function(deployer) {
  const initialSupply = web3.utils.toWei('1000000', 'ether'); // Initial total supply of tokens
  const tokenCap = web3.utils.toWei('1000000', 'ether'); // Maximum total supply of tokens

  deployer.deploy(PepesOfTheGalaxyToken, initialSupply, tokenCap);
};
