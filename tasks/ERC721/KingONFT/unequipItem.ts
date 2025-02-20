import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingV2, KingV2__factory } from "@orivium/types";

task("king-o-nft:unequip-item", "unequip stuff from king")
  .addParam("category", "category of the stuff to unequip")
  .addParam("kingId", "king id of the nft to unequip from")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king: KingV2 = KingV2__factory.connect(kingAddress, signer);

      const unequipTX = await king.unequipItem(
        taskArguments.kingId,
        taskArguments.category
      );
      await unequipTX.wait();
      console.log(
        `Successfully unequipped stuff ${taskArguments.type} from king ${taskArguments.kingId}`
      );
    }
  );
