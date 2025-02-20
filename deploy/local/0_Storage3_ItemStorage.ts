import { DeployFunction } from "hardhat-deploy/types";
import dotenv from "dotenv";

import { ItemStorage__factory } from "@orivium/types";
import {
  BUFFS,
  EFFECTS,
  ITEMS,
  ITEM_DATAS,
  ITEM_TYPES,
  LABELS,
  LABEL_START_INDEX,
} from "utils/storage/items";

dotenv.config();

const deployFunction: DeployFunction = async ({
  getNamedAccounts,
  deployments,
  ethers,
}) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  if (!deployer) throw new Error("missing deployer");

  await deploy("ItemStorage", {
    from: deployer,
    args: [deployer],
    log: true,
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
};

export default deployFunction;
deployFunction.tags = ["local"];
