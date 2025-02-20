import { Options } from "@layerzerolabs/lz-v2-utilities";
import { layerZeroEndpoints } from "./layerZeroEndpoint";

export const KING_BRIDGE_GATEWAY_ENFORCED_OPTIONS = {
  sepolia: [
    {
      eid: layerZeroEndpoints.arbitrumSepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const KING2D_BRIDGE_GATEWAY_ENFORCED_OPTIONS = {
  sepolia: [
    {
      eid: layerZeroEndpoints.arbitrumSepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const KING_O_NFT_ENFORCED_OPTIONS = {
  arbitrumSepolia: [
    {
      eid: layerZeroEndpoints.sepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const KING2D_O_NFT_ENFORCED_OPTIONS = {
  arbitrumSepolia: [
    {
      eid: layerZeroEndpoints.sepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const ORIVIUM_O_FT_ADAPTER_ENFORCED_OPTIONS = {
  sepolia: [
    {
      eid: layerZeroEndpoints.arbitrumSepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const ORIVIUM_O_FT_ENFORCED_OPTIONS = {
  arbitrumSepolia: [
    {
      eid: layerZeroEndpoints.sepolia.endpointId,
      msgType: 1,
      options: Options.newOptions()
        .addExecutorLzReceiveOption(1200000, 0)
        .toHex(),
    },
  ],
};

export const isSupportedNetworkFor = <
  T extends
    | typeof KING_BRIDGE_GATEWAY_ENFORCED_OPTIONS
    | typeof KING2D_BRIDGE_GATEWAY_ENFORCED_OPTIONS
    | typeof KING_O_NFT_ENFORCED_OPTIONS
    | typeof KING2D_O_NFT_ENFORCED_OPTIONS
    | typeof ORIVIUM_O_FT_ADAPTER_ENFORCED_OPTIONS
    | typeof ORIVIUM_O_FT_ENFORCED_OPTIONS,
>(
  network: string | number | symbol,
  enforcedOptions: T
): network is keyof T => {
  return network in enforcedOptions;
};
