import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dONFTMock, King2dONFTMock__factory } from "@orivium/types";

task("king2d-o-nft:bridge", "mint mock mint")
  .addParam("tokenId", "token id of the nft to bridge")
  .addParam("dstEid", "destination endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dAddress = (await hre.deployments.get("King2dONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king2d: King2dONFTMock = King2dONFTMock__factory.connect(
        king2dAddress,
        signer
      );
      const fee = await king2d.quote(
        taskArguments.dstEid,
        taskArguments.tokenId,
        signer.address,
        "0x",
        false
      );

      console.log(`Fee: ${fee.nativeFee}`);

      const bridgeTx = await king2d.bridge(
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
        `Bridged King2d ${taskArguments.tokenId} to ${taskArguments.dstEid}`
      );
    }
  );
