import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task("king-o-nft:stake", "mint mock mint")
  .addParam("tokenIds", "comma separated token ids to stake")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const stakingContractAddress = (
        await hre.deployments.get("KingONFTStaking")
      ).address;

      const { tokenIds } = taskArguments;
      await hre.run("staking:stake", {
        stakingContractAddress,
        tokenIds,
      });
    }
  );
