import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dONFT, King2dONFT__factory } from "@orivium/types";

task("king2d-o-nft:wallet", "get wallet of owner")
  .addParam("owner", "owner address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dONFTAddress = (await hre.deployments.get("King2dONFT"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");

      const king2dONFT: King2dONFT = King2dONFT__factory.connect(
        king2dONFTAddress,
        signer
      );
      const wallet = await king2dONFT.walletOfOwner(taskArguments.owner);
      console.log(
        `${taskArguments.owner} has ${wallet.length} king2dONFT nft(s)`
      );
      console.log(wallet);
    }
  );
