import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { King2dONFT, King2dONFT__factory } from "@orivium/types";

task("king2d-o-nft:set-peer", "set peer for king2dONFT")
  .addParam("dstEid", "destination endpoint id")
  .addParam("peerAddress", "destination contract address")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const king2dONFTAddress = (await hre.deployments.get("King2dONFT"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const king2dONFT: King2dONFT = King2dONFT__factory.connect(
        king2dONFTAddress,
        signer
      );

      // convert peer address to bytes32
      const peerAddressBytes32 = hre.ethers.zeroPadValue(
        taskArguments.peerAddress,
        32
      );
      console.log(`peerAddressBytes32: ${peerAddressBytes32}`);
      await king2dONFT.setPeer(taskArguments.dstEid, peerAddressBytes32);
      console.log(`
Successfully set peer:
    destination endpoint id: ${taskArguments.dstEid}
    peer contract address: ${taskArguments.peerAddress}`);
    }
  );
