const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("YieldingAndLendingContractModule", (m) => {
    const _stakingToken = "0xFa38B962562DF7F9eeD9d8Db3cC261053EFC263B"; // Replace with the token contract address on Sepolia
    const _rewardRate = 5;
    const _interestRate = 10;
    console.log("Deploying YieldingAndLendingContract with args:", {
        _stakingToken,
        _rewardRate,
        _interestRate,
      });

    const Contract = m.contract("YieldingAndLendingContract", { args: [_stakingToken, _rewardRate, _interestRate], });


    return { Contract };
});
