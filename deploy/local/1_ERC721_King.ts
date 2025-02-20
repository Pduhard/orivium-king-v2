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
  const erc721Item = await deployments.get("ERC721Item");

  // use KingONFT name for compatibility with KingONFT tasks
  await deploy("KingONFT", {
    from: deployer,
    contract: "KingV2Mock",
    args: [erc721Item.address],
    log: true,
  });
};

export default deployFunction;
deployFunction.tags = ["local"];
