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
  const kingONFT = await deployments.get("King2d");

  await deploy("King2dBridgeGateway", {
    from: deployer,
    contract: "BridgeGateway",
    args: [kingONFT.address, layerZeroEndpoint],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("King2dBridgeGateway")).address,
    contract: "contracts/ERC721/BridgeGateway.sol:BridgeGateway",
    constructorArguments: [kingONFT.address, layerZeroEndpoint],
  });
};

export default deployFunction;
deployFunction.tags = ["all", "prod", "King2dBridgeGateway"];
