import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";
import { isTestnet, isLocalNetwork } from "utils/env";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
  network,
  run,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  const itemStorage = (await deployments.get("ItemStorage")).address;

  await deploy("ERC721Item", {
    from: deployer,
    args: [itemStorage],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("ERC721Item")).address,
    contract: "contracts/ERC721/ERC721Item.sol:ERC721Item",
    constructorArguments: [],
  });
};

export default deployFunction;
deployFunction.tags = [
  "all",
  "prod",
  "ERC721Item",
  // dependencies
  "KingONFTStaking",
  "KingONFT",
];
