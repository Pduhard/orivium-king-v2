import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

const ORI_TOTAL_SUPPLY = 100000000000000000000000000n;

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  await deploy("ORIToken", {
    from: deployer,
    args: [ORI_TOTAL_SUPPLY],
    log: true,
  });
};

export default deployFunction;
deployFunction.tags = ["local"];
