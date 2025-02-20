import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task(
  "staking:set-rewards-per-unit-time",
  "set rewards per unit time for staking"
)
  .addParam("stakingContractAddress", "stakingContractAddress")
  .addParam("rewardsPerUnitTime", "rewards per unit time in wei")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const stakingContract = ERC721Staking__factory.connect(
        taskArguments.stakingContractAddress,
        signer
      );

      await stakingContract.setRewardsPerUnitTime(
        taskArguments.rewardsPerUnitTime
      );
      console.log(
        `Rewards per unit time set to ${taskArguments.rewardsPerUnitTime} seconds`
      );
    }
  );
