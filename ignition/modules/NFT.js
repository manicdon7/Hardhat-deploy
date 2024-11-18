const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NFTModule", (m) => {
    const nftContract = m.contract("ManicNFT");
    return { nftContract };
});


