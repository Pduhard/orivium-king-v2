import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFT, OriviumOFT__factory } from "@orivium/types";

task("orivium-o-ft:bridge", "bridge given amount of token to another chain")
  .addParam("amount", "amount of token to bridge")
  .addParam("dstEid", "destination chain endpoint id")
  .setAction(
    async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriviumOFTAddress = (await hre.deployments.get("OriviumOFT"))
        .address;

      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) return;
      const amount = hre.ethers.parseEther(taskArguments.amount);

      const oriviumOFT: OriviumOFT = OriviumOFT__factory.connect(
        oriviumOFTAddress,
        signer
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

      const fee = await oriviumOFT.quoteSend(sendParam, false);

      const messagingFee = {
        nativeFee: fee[0],
        lzTokenFee: fee[1],
      };
      console.log(`Fee: ${fee.nativeFee}`);

      const bridgeTx = await oriviumOFT.send(
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
