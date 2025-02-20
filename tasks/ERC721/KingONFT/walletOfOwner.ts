import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingONFT, KingONFT__factory } from "@orivium/types";

task("king-o-nft:wallet", "get wallet of owner")
  .addParam("owner", "owner address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingONFTAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");

      const kingONFT: KingONFT = KingONFT__factory.connect(
        kingONFTAddress,
        signer
      );
      const wallet = await kingONFT.walletOfOwner(taskArguments.owner);
      console.log(
        `${taskArguments.owner} has ${wallet.length} kingONFT nft(s)`
      );
      console.log(wallet);
    }
  );
