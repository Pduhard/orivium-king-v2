import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFTAdapter, OriviumOFT__factory } from "@orivium/types";

task("orivium-o-ft-adapter:set-peer", "set peer for OriviumOFTAdapter")
  .addParam("dstEid", "destination endpoint id")
  .addParam("peerAddress", "destination contract address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriviumOFTAddress = (await hre.deployments.get("OriviumOFTAdapter"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const oriviumOFT: OriviumOFTAdapter = OriviumOFT__factory.connect(
        oriviumOFTAddress,
        signer
      );

      // convert peer address to bytes32
      const peerAddressBytes32 = hre.ethers.zeroPadValue(
        taskArguments.peerAddress,
        32
      );
      console.log(`peerAddressBytes32: ${peerAddressBytes32}`);
      await oriviumOFT.setPeer(taskArguments.dstEid, peerAddressBytes32);
      console.log(`
Successfully set peer:
    destination endpoint id: ${taskArguments.dstEid}
    peer contract address: ${taskArguments.peerAddress}`);
    }
  );
