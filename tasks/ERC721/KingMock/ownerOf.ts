import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingMock, KingMock__factory } from "@orivium/types";

task("king-mock:owner-of", "retrieve owner of kingMock nft")
  .addParam("tokenId", "token id of the nft")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingMockAddress = (await hre.deployments.get("King")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const kingMock: KingMock = KingMock__factory.connect(
        kingMockAddress,
        signer
      );
      const ownerOf = await kingMock
        .ownerOf(taskArguments.tokenId)
        .catch(() => "NOT_MINTED");
      console.log(
        "Owner of KingMock NFT",
        taskArguments.tokenId,
        "is",
        ownerOf
      );
    }
  );
