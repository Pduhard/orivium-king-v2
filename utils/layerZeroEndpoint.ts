export const layerZeroEndpoints = {
  sepolia: {
    endpointId: 40161,
    endpointAddress: "0x6edce65403992e310a62460808c4b910d972f10f",
  },
  arbitrumSepolia: {
    endpointId: 40231,
    endpointAddress: "0x6edce65403992e310a62460808c4b910d972f10f",
  },
  xaiSepolia: {
    endpointId: 40251,
    endpointAddress: "0x6edce65403992e310a62460808c4b910d972f10f",
  },
  mainnet: {
    endpointId: 30101,
    endpointAddress: "0x1a44076050125825900e736c501f859c50fe728c",
  },
  arbitrum: {
    endpointId: 30110,
    endpointAddress: "0x1a44076050125825900e736c501f859c50fe728c",
  },
  xai: {
    endpointId: 30236,
    endpointAddress: "0x1a44076050125825900e736c501f859c50fe728c",
  },
};

export const isSupportedNetwork = (
  network: string | number
): network is keyof typeof layerZeroEndpoints => {
  return network in layerZeroEndpoints;
};
