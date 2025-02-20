import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import {
  BridgeGateway,
  BridgeGateway__factory,
  King2dMock,
  King2dMock__factory,
} from "@orivium/types";

task("king2d-mock:bridge", "mint mock mint")
  .addParam("tokenId", "token id of the nft to bridge")
  .addParam("dstEid", "destination endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dAddress = (await hre.deployments.get("King2d")).address;
      const bridgeGatewayAddress = (
        await hre.deployments.get("King2dBridgeGateway")
      ).address;

      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king2d: King2dMock = King2dMock__factory.connect(
        king2dAddress,
        signer
      );

      const bridgeGateway: BridgeGateway = BridgeGateway__factory.connect(
        bridgeGatewayAddress,
        signer
      );

      const approveTx = await king2d.approve(
        bridgeGatewayAddress,
        taskArguments.tokenId
      );
      await approveTx.wait();
      console.log(
        `Approved token ${taskArguments.tokenId} to ${bridgeGatewayAddress}`
      );

      const fee = await bridgeGateway.quote(
        taskArguments.dstEid,
        taskArguments.tokenId,
        signer.address,
        "0x",
        false
      );

      console.log(`Fee: ${fee.nativeFee}`);

      const bridgeTx = await bridgeGateway.bridge(
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
