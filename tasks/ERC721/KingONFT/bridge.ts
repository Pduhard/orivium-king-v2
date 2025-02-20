import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingONFTMock, KingONFTMock__factory } from "@orivium/types";

task("king-o-nft:bridge", "mint mock mint")
  .addParam("tokenId", "token id of the nft to bridge")
  .addParam("dstEid", "destination endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king: KingONFTMock = KingONFTMock__factory.connect(
        kingAddress,
        signer
      );
      const fee = await king.quote(
        taskArguments.dstEid,
        taskArguments.tokenId,
        signer.address,
        "0x",
        false
      );

      console.log(`Fee: ${fee.nativeFee}`);

      const bridgeTx = await king.bridge(
        taskArguments.dstEid,
        taskArguments.tokenId,
        "0x",
        false,
        {
          value: fee.nativeFee,
        }
      );

      await bridgeTx.wait();
      console.log(
        `Bridged King ${taskArguments.tokenId} to ${taskArguments.dstEid}`
      );
    }
  );
