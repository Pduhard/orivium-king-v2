import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task(
  "staking:get-staking-condition",
  "get time unit and reward per time unit for staking program"
)
  .addParam("stakingContractAddress", "stakingContractAddress")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const stakingContract = ERC721Staking__factory.connect(
        taskArguments.stakingContractAddress,
        signer
      );

      const [timeUnit, rewardPerTimeUnit] = await Promise.all([
        stakingContract.getTimeUnit(),
        stakingContract.getRewardsPerUnitTime(),
      ]);

      console.log(`Time unit = ${timeUnit} seconds`);
      console.log(
        `Reward per time unit = ${hre.ethers.formatEther(rewardPerTimeUnit)} $ORI (${rewardPerTimeUnit} $wORI)`
      );
    }
  );
