import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task("king-o-nft:claim-rewards", "claim rewards for signer").setAction(
  async (_: TaskArguments, hre: HardhatRuntimeEnvironment) => {
    const stakingContractAddress = (
      await hre.deployments.get("KingONFTStaking")
    ).address;

    await hre.run("staking:claim-rewards", {
      stakingContractAddress,
    });
  }
);
