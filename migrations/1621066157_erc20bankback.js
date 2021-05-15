const Erc20Bank = artifacts.require("./Erc20BankBack.sol")

module.exports = function(_deployer, network, account) {

  // Use deployer to state migration tasks.
  _deployer.deploy(Erc20Bank, 
    "HiSKIO Token",
    "HT",
  )
};
