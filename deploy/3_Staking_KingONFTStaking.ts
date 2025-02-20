import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

import { isSupportedNetwork } from "utils/layerZeroEndpoint";
import { isLocalNetwork, isTestnet } from "utils/env";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
  network,
  run,
  ethers,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");
  if (!isSupportedNetwork(network.name)) throw new Error("unsupported network");

  const kingONFT = await deployments.get("KingONFT");
  const oriToken = await deployments.get("ORIToken");

  const timeUnit = 60 * 60; // 1 hour
  const rewardsPerUnitTime = ethers.parseEther("0.1"); // 0.1 ORI per hour

  await deploy("KingONFTStaking", {
    from: deployer,
    contract: "ERC721Staking",
    args: [kingONFT.address, oriToken.address, timeUnit, rewardsPerUnitTime],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("KingONFTStaking")).address,
    contract: "contracts/ERC721/ERC721Staking.sol:ERC721Staking",
    constructorArguments: [
      kingONFT.address,
      oriToken.address,
      timeUnit,
      rewardsPerUnitTime,
    ],
  });
};

export default deployFunction;
deployFunction.tags = ["all", "prod", "KingONFTStaking"];
