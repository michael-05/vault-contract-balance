import { ethers } from "hardhat";

async function main() {

  const [deployer] = await ethers.getSigners();
  const VaultContract = await ethers.getContractFactory("VaultContract");
  const vaultContract = await VaultContract.deploy();
  await vaultContract.deployed();
  console.log("deployed contract address: ", vaultContract.address);
  console.log("contrat was deployed by account: ", deployer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
