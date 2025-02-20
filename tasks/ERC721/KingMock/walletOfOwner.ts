import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingMock, KingMock__factory } from "@orivium/types";

task("king-mock:wallet", "get wallet of owner")
  .addParam("owner", "owner address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingMockAddress = (await hre.deployments.get("KingMock")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");

      const kingMock: KingMock = KingMock__factory.connect(
        kingMockAddress,
        signer
      );
      const wallet = await kingMock.walletOfOwner(taskArguments.owner);
      console.log(
        `${taskArguments.owner} has ${wallet.length} kingMock nft(s)`
      );
      console.log(wallet);
    }
  );
