import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

task(
  "king-o-nft:get-staking-condition",
  "get time unit and reward per time unit for staking program"
).setAction(async (_: TaskArguments, hre: HardhatRuntimeEnvironment) => {
  const stakingContractAddress = (await hre.deployments.get("KingONFTStaking"))
    .address;

  await hre.run("staking:get-staking-condition", {
    stakingContractAddress,
  });
});
