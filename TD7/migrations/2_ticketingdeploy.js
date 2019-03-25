var MyContract = artifacts.require("./contracts/ticketingSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(MyContract);
};