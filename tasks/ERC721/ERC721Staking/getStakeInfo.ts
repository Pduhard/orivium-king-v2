import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task("staking:get-stake-info", "get stake info for a given staker")
  .addParam("stakingContractAddress", "stakingContractAddress")
  .addParam("address", "address of the staker")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");
      const stakingContract = ERC721Staking__factory.connect(
        taskArguments.stakingContractAddress,
        signer
      );

      const { _tokensStaked: tokensStaked, _rewards: rewards } =
        await stakingContract.getStakeInfo(taskArguments.address);

      console.log(`Token staked = ${tokensStaked.join(", ")}`);
      console.log(
        `Available rewards = ${hre.ethers.formatEther(rewards)} $ORI (${rewards} $wORI)`
      );
    }
  );
