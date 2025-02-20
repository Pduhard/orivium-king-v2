import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { BridgeGateway, BridgeGateway__factory } from "@orivium/types";

task("king-bridge-gateway:set-peer", "set peer for bridgeGateway")
  .addParam("dstEid", "destination endpoint id")
  .addParam("peerAddress", "destination contract address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const bridgeGatewayAddress = (
        await hre.deployments.get("KingBridgeGateway")
      ).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const bridgeGateway: BridgeGateway = BridgeGateway__factory.connect(
        bridgeGatewayAddress,
        signer
      );

      // convert peer address to bytes32
      const peerAddressBytes32 = hre.ethers.zeroPadValue(
        taskArguments.peerAddress,
        32
      );
      console.log(`peerAddressBytes32: ${peerAddressBytes32}`);
      await bridgeGateway.setPeer(taskArguments.dstEid, peerAddressBytes32);
      console.log(`
Successfully set peer:
    destination endpoint id: ${taskArguments.dstEid}
    peer contract address: ${taskArguments.peerAddress}`);
    }
  );
