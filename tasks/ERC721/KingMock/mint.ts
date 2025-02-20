import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingMock, KingMock__factory } from "@orivium/types";

task("king-mock:mint", "mint mock mint")
  .addParam("tokenId", "token id of the nft to mint")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingAddress = (await hre.deployments.get("King")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king: KingMock = KingMock__factory.connect(kingAddress, signer);
      const mintTx = await king.mint(signer.address, taskArguments.tokenId);
      await mintTx.wait();
      console.log(`Minted token ${taskArguments.tokenId} to ${signer.address}`);
    }
  );
