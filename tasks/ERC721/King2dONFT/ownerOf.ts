import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dONFT, King2dONFT__factory } from "@orivium/types";

task("king2d-o-nft:owner-of", "retrieve owner of king2dONFT nft")
  .addParam("tokenId", "token id of the nft")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dONFTAddress = (await hre.deployments.get("King2dONFT"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king2dONFT: King2dONFT = King2dONFT__factory.connect(
        king2dONFTAddress,
        signer
      );
      const ownerOf = await king2dONFT.ownerOf(taskArguments.tokenId);
      console.log(
        "Owner of King2dONFT NFT",
        taskArguments.tokenId,
        "is",
        ownerOf
      );
    }
  );
