import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFT, OriviumOFT__factory } from "@orivium/types";
import {
  isSupportedNetworkFor,
  ORIVIUM_O_FT_ENFORCED_OPTIONS,
} from "utils/enforcedOptions";

task(
  "orivium-o-ft:set-enforced-options",
  "set enforced options for OriviumOFT"
).setAction(async (_: TaskArguments, hre: HardhatRuntimeEnvironment) => {
  const oriviumOFTAddress = (await hre.deployments.get("OriviumOFT")).address;
  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  if (!signer) throw new Error("missing signer");
  if (!isSupportedNetworkFor(hre.network.name, ORIVIUM_O_FT_ENFORCED_OPTIONS))
    throw new Error("unsupported network");
  const oriviumOFT: OriviumOFT = OriviumOFT__factory.connect(
    oriviumOFTAddress,
    signer
  );
  const enforcedOptions = ORIVIUM_O_FT_ENFORCED_OPTIONS[hre.network.name];

  await oriviumOFT.setEnforcedOptions(enforcedOptions);
  console.log("Successfully set enforced options for OriviumOFT");
});
