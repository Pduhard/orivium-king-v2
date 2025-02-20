import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import {
  BridgeGateway,
  BridgeGateway__factory,
  KingMock,
  KingMock__factory,
} from "@orivium/types";

task("king-mock:bridge", "mint mock mint")
  .addParam("tokenId", "token id of the nft to bridge")
  .addParam("dstEid", "destination endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingAddress = (await hre.deployments.get("King")).address;
      const bridgeGatewayAddress = (
        await hre.deployments.get("KingBridgeGateway")
      ).address;

      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king: KingMock = KingMock__factory.connect(kingAddress, signer);

      const bridgeGateway: BridgeGateway = BridgeGateway__factory.connect(
        bridgeGatewayAddress,
        signer
      );

      const approveTx = await king.approve(
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
        `Bridged King ${taskArguments.tokenId} to ${taskArguments.dstEid}`
      );
    }
  );
