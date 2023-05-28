var vrf = artifacts.require("VRFD20");

module.exports = function (deployer) {
  deployer.deploy(vrf, 2199);
};
