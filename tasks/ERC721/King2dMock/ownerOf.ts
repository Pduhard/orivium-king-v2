import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dMock, King2dMock__factory } from "@orivium/types";

task("king2d-mock:owner-of", "retrieve owner of king2dMock nft")
  .addParam("tokenId", "token id of the nft")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dMockAddress = (await hre.deployments.get("King2d")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king2dMock: King2dMock = King2dMock__factory.connect(
        king2dMockAddress,
        signer
      );
      const ownerOf = await king2dMock
        .ownerOf(taskArguments.tokenId)
        .catch(() => "NOT_MINTED");
      console.log(
        "Owner of King2dMock NFT",
        taskArguments.tokenId,
        "is",
        ownerOf
      );
    }
  );
