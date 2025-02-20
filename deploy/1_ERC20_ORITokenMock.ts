import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

import { isLocalNetwork, isTestnet } from "utils/env";

const ORI_TOTAL_SUPPLY = 100000000000000000000000000n;

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

  await deploy("ORIToken", {
    from: deployer,
    args: [ORI_TOTAL_SUPPLY],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("ORIToken")).address,
    contract: "contracts/Mock/ORIToken.sol:ORIToken",
    constructorArguments: [ORI_TOTAL_SUPPLY],
  });
};

export default deployFunction;
deployFunction.tags = [
  "all",
  "mock",
  "ORIToken",
  // do not set dependencies for mocks
  // "KingONFTStaking",
  // "OriviumOFTAdapter",
];
