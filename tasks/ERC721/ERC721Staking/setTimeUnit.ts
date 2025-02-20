import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task("staking:set-time-unit", "set time unit for staking")
  .addParam("stakingContractAddress", "stakingContractAddress")
  .addParam("timeUnit", "time unit in seconds")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const stakingContract = ERC721Staking__factory.connect(
        taskArguments.stakingContractAddress,
        signer
      );

      await stakingContract.setTimeUnit(taskArguments.timeUnit);
      console.log(`Time unit set to ${taskArguments.timeUnit} seconds`);
    }
  );
