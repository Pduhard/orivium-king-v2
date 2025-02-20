import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dMock, King2dMock__factory } from "@orivium/types";

task("king2d-mock:wallet", "get wallet of owner")
  .addParam("owner", "owner address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dMockAddress = (await hre.deployments.get("King2d")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");

      const king2dMock: King2dMock = King2dMock__factory.connect(
        king2dMockAddress,
        signer
      );
      const wallet = await king2dMock.walletOfOwner(taskArguments.owner);
      console.log(
        `${taskArguments.owner} has ${wallet.length} king2dMock nft(s)`
      );
      console.log(wallet);
    }
  );
