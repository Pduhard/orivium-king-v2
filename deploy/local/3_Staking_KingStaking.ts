import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
  ethers,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  const kingV2 = await deployments.get("KingONFT");
  const oriToken = await deployments.get("ORIToken");

  const timeUnit = 60 * 60; // 1 hour
  const rewardsPerUnitTime = ethers.parseEther("0.1"); // 0.1 ORI per hour

  // use KingONFTStaking name for compatibility with KingONFT tasks
  await deploy("KingONFTStaking", {
    from: deployer,
    contract: "ERC721Staking",
    args: [kingV2.address, oriToken.address, timeUnit, rewardsPerUnitTime],
    log: true,
  });
};

export default deployFunction;
deployFunction.tags = ["local"];
