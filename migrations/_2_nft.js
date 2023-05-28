var nft = artifacts.require("GameItem")

module.exports = function (deployer) {
  deployer.deploy(nft);
};
