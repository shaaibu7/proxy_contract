const { ethers, upgrades } = require("hardhat");

async function main() {
  const TaskEscrow = await ethers.getContractFactory("TaskEscrow");
  const taskEscrowImpl = await upgrades.deployImplementation(TaskEscrow);
  console.log("TaskEscrow impl:", taskEscrowImpl);

  const TaskFactory = await ethers.getContractFactory("TaskFactory");
  const factoryProxy = await upgrades.deployProxy(TaskFactory, [taskEscrowImpl], {
    initializer: "initialize",
  });

  console.log("TaskFactory proxy deployed at:", await factoryProxy.getAddress());
}

main();
