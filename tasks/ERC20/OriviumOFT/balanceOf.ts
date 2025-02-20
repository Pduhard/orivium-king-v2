import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFT, OriviumOFT__factory } from "@orivium/types";

task(
  "orivium-o-ft:balance-of",
  "retrieve OriviumOFT balance for the given address"
)
  .addOptionalParam("address", "address to check balance for (default: signer)")
  .setAction(
    async (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) => {
      const oriviumOFTAddress = (await hre.deployments.get("OriviumOFT"))
        .address;
      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];
      if (!signer) throw new Error("missing signer");
      const oriviumOFT: OriviumOFT = OriviumOFT__factory.connect(
        oriviumOFTAddress,
        signer
      );

      const balance = await oriviumOFT.balanceOf(
        taskArgs.address ?? signer.address
      );
      const OriviumOFTBalance = hre.ethers.formatEther(balance);

      console.log(
        `Balance of ${taskArgs.address} is ${OriviumOFTBalance} $ORI (${balance} $wORI)`
      );
    }
  );
