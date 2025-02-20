import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingONFT, KingONFT__factory } from "@orivium/types";

task("king-o-nft:owner-of", "retrieve owner of kingONFT nft")
  .addParam("tokenId", "token id of the nft")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingONFTAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const kingONFT: KingONFT = KingONFT__factory.connect(
        kingONFTAddress,
        signer
      );
      const ownerOf = await kingONFT
        .ownerOf(taskArguments.tokenId)
        .catch(() => "NOT_MINTED");
      console.log(
        "Owner of KingONFT NFT",
        taskArguments.tokenId,
        "is",
        ownerOf
      );
    }
  );
