import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { OriviumOFTAdapter, OriviumOFTAdapter__factory } from "@orivium/types";
import {
  isSupportedNetworkFor,
  ORIVIUM_O_FT_ADAPTER_ENFORCED_OPTIONS,
} from "utils/enforcedOptions";

task(
  "orivium-o-ft-adapter:set-enforced-options",
  "set enforced options for OriviumOFTAdapter"
).setAction(async (_: TaskArguments, hre: HardhatRuntimeEnvironment) => {
  const oriviumOFTAdapterAddress = (
    await hre.deployments.get("OriviumOFTAdapter")
  ).address;
  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  if (!signer) throw new Error("missing signer");
  if (
    !isSupportedNetworkFor(
      hre.network.name,
      ORIVIUM_O_FT_ADAPTER_ENFORCED_OPTIONS
    )
  )
    throw new Error("unsupported network");
  const oriviumOFTAdapter: OriviumOFTAdapter =
    OriviumOFTAdapter__factory.connect(oriviumOFTAdapterAddress, signer);
  const enforcedOptions =
    ORIVIUM_O_FT_ADAPTER_ENFORCED_OPTIONS[hre.network.name];

  await oriviumOFTAdapter.setEnforcedOptions(enforcedOptions);
  console.log("Successfully set enforced options for OriviumOFTAdapter");
});
