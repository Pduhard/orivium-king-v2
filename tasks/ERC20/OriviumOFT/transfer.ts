import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFT, OriviumOFT__factory } from "@orivium/types";

task("orivium-o-ft:transfer", "transfer given amount of token to given address")
  .addParam("amount", "amount of token to transfer")
  .addParam("to", "address to transfer token to")
  .setAction(
    async (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriviumOFTAddress = (await hre.deployments.get("OriviumOFT"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");
      const oriviumOFT: OriviumOFT = OriviumOFT__factory.connect(
        oriviumOFTAddress,
        signer
      );

      const amount = hre.ethers.parseEther(taskArgs.amount);
      await oriviumOFT.transfer(taskArgs.to, amount);
      console.log(`Transferred ${taskArgs.amount} to ${taskArgs.to}`);
    }
  );
