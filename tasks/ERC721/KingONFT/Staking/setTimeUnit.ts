import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task("king-o-nft:set-time-unit", "set time unit for staking")
  .addParam("timeUnit", "time unit in seconds")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const stakingContractAddress = (
        await hre.deployments.get("KingONFTStaking")
      ).address;

      const { timeUnit } = taskArguments;
      await hre.run("staking:set-time-unit", {
        stakingContractAddress,
        timeUnit,
      });
    }
  );
