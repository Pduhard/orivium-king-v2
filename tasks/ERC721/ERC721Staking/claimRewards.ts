import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task("staking:claim-rewards", "claim rewards for signer")
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

      await stakingContract.claimRewards();
      console.log(`Rewards claimed`);
    }
  );
