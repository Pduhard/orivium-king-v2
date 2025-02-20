import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Staking__factory } from "@orivium/types";

task("staking:withdraw", "mint mock mint")
  .addParam("tokenIds", "comma separated token ids to withdraw")
  .addParam("stakingContractAddress", "staking contract address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const stakingContract = ERC721Staking__factory.connect(
        taskArguments.stakingContractAddress,
        signer
      );

      const tokenIds = (taskArguments.tokenIds as string)
        .split(",")
        .map((x: string) => parseInt(x, 10));

      const withdrawTx = await stakingContract.withdraw(tokenIds);

      await withdrawTx.wait();
      console.log(`Withdrawn ERC721s ${taskArguments.tokenIds}`);
    }
  );
