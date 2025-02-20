import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { ERC721Item, ERC721Item__factory } from "@orivium/types";

task("item:mint", "mint kig stuff")
  .addParam("tokenId", "token id of the nft to mint")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingAddress = (await hre.deployments.get("ERC721Item")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const item: ERC721Item = ERC721Item__factory.connect(kingAddress, signer);
      const mintTx = await item.mint(signer.address, taskArguments.tokenId);

      await mintTx.wait();
      console.log(`Minted token ${taskArguments.tokenId} to ${signer.address}`);
    }
  );
