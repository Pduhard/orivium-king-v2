import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingV2__factory, ERC721Item__factory } from "@orivium/types";

task("king-o-nft:equip-item", "equip item to king")
  .addParam("kingId", "id of the king nft to equip item to")
  .addParam("itemId", "id of the item nft to equip")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const itemAddress = (await hre.deployments.get("ERC721Item")).address;
      const kingAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const item = ERC721Item__factory.connect(itemAddress, signer);
      const king = KingV2__factory.connect(kingAddress, signer);

      if ((await item.getApproved(taskArguments.itemId)) !== kingAddress) {
        const approveTx = await item.approve(kingAddress, taskArguments.itemId);
        await approveTx.wait();
        console.log(`Approved item ${taskArguments.itemId} for king`);
      }

      const equipItem = await king.equipItem(
        taskArguments.kingId,
        taskArguments.itemId
      );
      await equipItem.wait();
      console.log(
        `Equipped Item ${taskArguments.itemId} to king ${taskArguments.kingId}`
      );
    }
  );
