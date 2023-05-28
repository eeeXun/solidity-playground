var token = artifacts.require("MyToken");

module.exports = function (deployer) {
  deployer.deploy(token);
};
