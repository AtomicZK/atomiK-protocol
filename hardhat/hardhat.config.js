require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
require("dotenv").config({ path: ".env" });

const XINFIN_NETWORK_URL = process.env.XINFIN_NETWORK_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const APOTHEM_NETWORK_URL = process.env.APOTHEM_NETWORK_URL;


module.exports = {
  solidity: "0.5.16",
  networks: {
    xinfin: {
      url: XINFIN_NETWORK_URL,
      accounts: [PRIVATE_KEY],
    },
    apothem: {
      url: APOTHEM_NETWORK_URL,
      accounts: [PRIVATE_KEY],
    }
  },
};