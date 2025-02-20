import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";
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

  await deploy("King2d", {
    from: deployer,
    contract: "King2dMock",
    args: [],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("King2d")).address,
    contract: "contracts/Mock/King2d.sol:King2dMock",
    constructorArguments: [],
  });
};

export default deployFunction;
deployFunction.tags = [
  "all",
  "mock",
  "King2dMock",
  // do not set dependencies for mocks
  // "King2dBridgeGateway",
];
