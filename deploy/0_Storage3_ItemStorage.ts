import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";
import { isLocalNetwork, isTestnet } from "utils/env";
import {
  BUFFS,
  EFFECTS,
  ITEMS,
  ITEM_DATAS,
  ITEM_TYPES,
  LABELS,
  LABEL_START_INDEX,
} from "utils/storage/items";
import { ItemStorage__factory } from "@orivium/types";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
  network,
  run,
  ethers,
}) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  await deploy("ItemStorage", {
    from: deployer,
    args: [deployer],
    log: true,
    waitConfirmations: isLocalNetwork(network.name) ? 0 : 3,
  });

  const itemStorage = await get("ItemStorage");
  const itemStorageContract = ItemStorage__factory.connect(
    itemStorage.address,
    await ethers.getSigner(deployer)
  );

  await itemStorageContract.updateMetadata(
    LABELS,
    LABEL_START_INDEX,
    BUFFS,
    EFFECTS,
    ITEM_DATAS,
    ITEM_TYPES,
    ITEMS
  );

  if (isTestnet(network.name) || isLocalNetwork(network.name)) return;

  await run("verify:verify", {
    address: (await deployments.get("ItemStorage")).address,
    contract: "contracts/ERC721/ItemStorage.sol:ItemStorage",
    constructorArguments: [deployer],
  });
};

export default deployFunction;
deployFunction.tags = [
  "all",
  "prod",
  "ItemStorage",
  // dependencies
  "KingONFTStaking",
  "KingONFT",
  "ERC721Item",
];
