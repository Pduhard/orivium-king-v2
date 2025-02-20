import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import {
  OriviumOFTAdapter,
  OriviumOFTAdapter__factory,
  ORIToken,
  ORIToken__factory,
} from "@orivium/types";

task(
  "orivium-o-ft-adapter:bridge",
  "bridge given amount of token to another chain"
)
  .addParam("amount", "amount of token to bridge")
  .addParam("dstEid", "destination chain endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriTokenAddress = (await hre.deployments.get("ORIToken")).address;
      const oriviumOFTAdapterAddress = (
        await hre.deployments.get("OriviumOFTAdapter")
      ).address;

      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const oriToken: ORIToken = ORIToken__factory.connect(
        oriTokenAddress,
        signer
      );
      const amount = hre.ethers.parseEther(taskArguments.amount);

      const oriviumOFTAdapter: OriviumOFTAdapter =
        OriviumOFTAdapter__factory.connect(oriviumOFTAdapterAddress, signer);

      const approveTx = await oriToken.approve(
        oriviumOFTAdapterAddress,
        amount
      );
      await approveTx.wait();
      console.log(
        `Approve spending ${taskArguments.amount} (${amount} wei) by ${oriviumOFTAdapterAddress}`
      );
      const bytesAddress = hre.ethers.zeroPadValue(signer.address, 32);

      const sendParam = {
        dstEid: taskArguments.dstEid,
        to: bytesAddress,
        amountLD: amount,
        minAmountLD: amount,
        extraOptions: "0x",
        composeMsg: "0x",
        oftCmd: "0x",
      };

      const fee = await oriviumOFTAdapter.quoteSend(sendParam, false);

      const messagingFee = {
        nativeFee: fee[0],
        lzTokenFee: fee[1],
      };
      console.log(`Fee: ${fee.nativeFee}`);

      const bridgeTx = await oriviumOFTAdapter.send(
        sendParam,
        messagingFee,
        signer.address,
        { value: fee.nativeFee }
      );

      await bridgeTx.wait();
      console.log(
        `Successfully bridged ${taskArguments.amount} to ${taskArguments.dstEid} with fee ${fee.nativeFee}`
      );
    }
  );
