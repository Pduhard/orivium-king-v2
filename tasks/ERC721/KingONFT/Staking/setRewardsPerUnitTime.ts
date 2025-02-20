import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task(
  "king-o-nft:set-rewards-per-unit-time",
  "set rewards per unit time for staking"
)
  .addParam("rewardsPerUnitTime", "rewards per unit time in wei")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const stakingContractAddress = (
        await hre.deployments.get("KingONFTStaking")
      ).address;

      const { rewardsPerUnitTime } = taskArguments;
      await hre.run("staking:set-rewards-per-unit-time", {
        stakingContractAddress,
        rewardsPerUnitTime,
      });
    }
  );
