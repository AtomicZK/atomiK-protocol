// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const [deployer] = await hre.ethers.getSigners();
  // make sure to change the name of your contract
  const Factory = await hre.ethers.getContractFactory("UniswapV2Factory");
  const factory = await Factory.deploy(deployer.address);
  await factory.deployed();


  let token1Address, token2Address;
  if (network === 'apothem') {
    token1Address = '';
    token2Address = '';
  } else {
    const Token1 = await hre.ethers.getContractFactory("Token1");
    const Token2 = await hre.ethers.getContractFactory("Token2");

    const token1 = await Token1.deploy();
    const token2 = await Token2.deploy();

    token1Address = await token1.deployed();
    token2Address = await token2.deployed();
  }

  await factory.createPair(token1Address.address, token2Address.address);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });