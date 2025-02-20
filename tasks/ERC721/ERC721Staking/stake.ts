import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721__factory, ERC721Staking__factory } from "@orivium/types";

task("staking:stake", "mint mock mint")
  .addParam("tokenIds", "comma separated token ids to stake")
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

      const erc721ContractAddress = await stakingContract.stakingToken();

      const erc721 = ERC721__factory.connect(erc721ContractAddress, signer);

      const tokenIds = (taskArguments.tokenIds as string)
        .split(",")
        .map((x: string) => parseInt(x, 10));

      const approveForAllTx = await erc721.setApprovalForAll(
        stakingContract.target,
        true
      );

      await approveForAllTx.wait();
      console.log(
        `Set approval for all on ${erc721.target} to ${stakingContract.target}`
      );

      const stakeTx = await stakingContract.stake(tokenIds);

      await stakeTx.wait();
      console.log(`Staked ERC721s ${taskArguments.tokenIds}`);
    }
  );
