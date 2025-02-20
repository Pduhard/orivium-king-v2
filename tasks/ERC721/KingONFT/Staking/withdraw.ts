import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task("king-o-nft:withdraw", "mint mock mint")
  .addParam("tokenIds", "comma separated token ids to withdraw")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const stakingContractAddress = (
        await hre.deployments.get("KingONFTStaking")
      ).address;

      const { tokenIds } = taskArguments;
      await hre.run("staking:withdraw", {
        stakingContractAddress,
        tokenIds,
      });
    }
  );
