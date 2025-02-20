import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import { BridgeGateway, BridgeGateway__factory } from "@orivium/types";
import {
  isSupportedNetworkFor,
  KING_BRIDGE_GATEWAY_ENFORCED_OPTIONS,
} from "utils/enforcedOptions";

task(
  "king-bridge-gateway:set-enforced-options",
  "set enforced options for king bridge gateway"
).setAction(async (_: TaskArguments, hre: HardhatRuntimeEnvironment) => {
  const bridgeGatewayAddress = (await hre.deployments.get("KingBridgeGateway"))
    .address;
  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  if (!signer) throw new Error("missing signer");
  if (
    !isSupportedNetworkFor(
      hre.network.name,
      KING_BRIDGE_GATEWAY_ENFORCED_OPTIONS
    )
  )
    throw new Error("unsupported network");
  const bridgeGateway: BridgeGateway = BridgeGateway__factory.connect(
    bridgeGatewayAddress,
    signer
  );
  const enforcedOptions =
    KING_BRIDGE_GATEWAY_ENFORCED_OPTIONS[hre.network.name];

  await bridgeGateway.setEnforcedOptions(enforcedOptions);
  console.log("Successfully set enforced options for KingBridgeGateway");
});
