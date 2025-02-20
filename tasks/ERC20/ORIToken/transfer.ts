import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ORIToken, ORIToken__factory } from "@orivium/types";

task("ori-token:transfer", "transfer given amount of token to given address")
  .addParam("amount", "amount of token to transfer")
  .addParam("to", "address to transfer token to")
  .setAction(
    async (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriTokenAddress = (await hre.deployments.get("ORIToken")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");
      const oriToken: ORIToken = ORIToken__factory.connect(
        oriTokenAddress,
        signer
      );

      const amount = hre.ethers.parseEther(taskArgs.amount);
      await oriToken.transfer(taskArgs.to, amount);
      console.log(`Transferred ${taskArgs.amount} to ${taskArgs.to}`);
    }
  );
