import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { KingONFT, KingONFT__factory } from "@orivium/types";

task("king-o-nft:set-peer", "set peer for kingONFT")
  .addParam("dstEid", "destination endpoint id")
  .addParam("peerAddress", "destination contract address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const kingONFTAddress = (await hre.deployments.get("KingONFT")).address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const kingONFT: KingONFT = KingONFT__factory.connect(
        kingONFTAddress,
        signer
      );

      // convert peer address to bytes32
      const peerAddressBytes32 = hre.ethers.zeroPadValue(
        taskArguments.peerAddress,
        32
      );
      console.log(`peerAddressBytes32: ${peerAddressBytes32}`);
      await kingONFT.setPeer(taskArguments.dstEid, peerAddressBytes32);
      console.log(`
Successfully set peer:
    destination endpoint id: ${taskArguments.dstEid}
    peer contract address: ${taskArguments.peerAddress}`);
    }
  );
