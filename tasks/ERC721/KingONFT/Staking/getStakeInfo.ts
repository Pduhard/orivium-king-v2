import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task("king-o-nft:get-stake-info", "get stake info for a given staker")
  .addParam("address", "address of the staker")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const { address } = taskArguments;
      const stakingContractAddress = (
        await hre.deployments.get("KingONFTStaking")
      ).address;

      await hre.run("staking:get-stake-info", {
        stakingContractAddress,
        address,
      });
    }
  );
