const hre = require("hardhat");

async function main() {
  // Set initial reward rate (in wei per GB per day), e.g. 0.01 ether per GB per day
  const initialRewardRate = hre.ethers.utils.parseEther("0.01");

  const Project = await hre.ethers.getContractFactory("Project");
  const project = await Project.deploy(initialRewardRate);

  await project.deployed();

  console.log("Decentralized Storage Incentive contract deployed to:", project.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
