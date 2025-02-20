import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

import {
  layerZeroEndpoints,
  isSupportedNetwork,
} from "utils/layerZeroEndpoint";
import { isLocalNetwork, isTestnet } from "utils/env";

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
  if (!isSupportedNetwork(network.name)) throw new Error("unsupported network");

  const layerZeroEndpoint = layerZeroEndpoints[network.name].endpointAddress;
  const token = await deployments.get("ORIToken");

  await deploy("OriviumOFTAdapter", {
    from: deployer,
    args: [token.address, layerZeroEndpoint],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("OriviumOFTAdapter")).address,
    contract: "contracts/ERC20/OriviumOFTAdapter.sol:OriviumOFTAdapter",
    constructorArguments: [token.address, layerZeroEndpoint],
  });
};

export default deployFunction;
deployFunction.tags = ["all", "prod", "OriviumOFTAdapter"];
