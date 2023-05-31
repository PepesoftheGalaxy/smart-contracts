const PepesOfTheGalaxyToken = artifacts.require("PepesOfTheGalaxyToken");

module.exports = function(deployer) {
  const initialSupply = web3.utils.toWei('8880000000', 'ether'); // 8,880,000,000 maximum total supply of tokens
  const tokenCap = web3.utils.toWei('8880000000', 'ether'); // 8,880,000,000 maximum total supply of tokens

  deployer.deploy(PepesOfTheGalaxyToken, initialSupply, tokenCap);
};
