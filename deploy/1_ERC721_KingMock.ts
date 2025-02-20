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

  await deploy("King", {
    from: deployer,
    contract: "KingMock",
    args: [],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("King")).address,
    contract: "contracts/Mock/King.sol:KingMock",
    constructorArguments: [],
  });
};

export default deployFunction;
deployFunction.tags = [
  "all",
  "mock",
  "KingMock",
  // do not set dependencies for mocks
  // "KingBridgeGateway",
];
