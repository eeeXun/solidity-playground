var nft = artifacts.require("MyNFT")

module.exports = function (deployer) {
  deployer.deploy(nft);
};
