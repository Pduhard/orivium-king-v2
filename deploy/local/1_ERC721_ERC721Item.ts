import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  const itemStorage = (await deployments.get("ItemStorage")).address;

  await deploy("ERC721Item", {
    from: deployer,
    args: [itemStorage],
    log: true,
  });
};

export default deployFunction;
deployFunction.tags = ["local"];
