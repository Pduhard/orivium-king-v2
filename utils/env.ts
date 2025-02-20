/* eslint-disable import/prefer-default-export */
export const isLocalNetwork = (network: string) => {
  return ["hardhat", "localhost"].includes(network);
};

export const isTestnet = (network: string) => {
  return [
    "sepolia",
    "goerli",
    "arbitrumSepolia",
    "xaiSepolia",
    "xaiGoerli",
  ].includes(network);
};
