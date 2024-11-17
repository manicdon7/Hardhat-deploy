require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
require("dotenv").config();

module.exports = {
   solidity: "0.8.27",
   ignition: {
      modules: ["./ignition/modules/YieldingAndLendingContract.js"]
   },
   networks: {
      sepolia: {
         url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
         accounts: [process.env.WALLET_PRIVATE_KEY]
      }
   },
   etherscan: {
      apiKey: {
         sepolia: process.env.ETHERSCAN_API_KEY
      }
   }
};
