var price = artifacts.require("PriceConsumerV3")

module.exports = function (deployer) {
  deployer.deploy(price);
};
