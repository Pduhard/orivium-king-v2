# deploy contracts to testnet

yarn hardhat deploy --network sepolia --tags mocks

yarn hardhat deploy --network sepolia --tags OriviumOFTAdapter
yarn hardhat deploy --network arbitrumSepolia --tags OriviumOFT

yarn hardhat deploy --network sepolia --tags BridgeGateway

yarn hardhat deploy --network arbitrumSepolia --tags KingONFT,King2dONFT


# set peers 

OriviumOFT=$(cat deployments/arbitrumSepolia/OriviumOFT.json | grep "address" -m1 |  awk -F'["]' '{print $4}')
OriviumOFTAdapter=$(cat deployments/sepolia/OriviumOFTAdapter.json | grep "address" -m1 |  awk -F'["]' '{print $4}')

KingONFT=$(cat deployments/arbitrumSepolia/KingONFT.json | grep "address" -m1 |  awk -F'["]' '{print $4}')
King2dONFT=$(cat deployments/arbitrumSepolia/King2dONFT.json | grep "address" -m1 |  awk -F'["]' '{print $4}')
KingBridgeGateway=$(cat deployments/sepolia/KingBridgeGateway.json | grep "address" -m1 |  awk -F'["]' '{print $4}')
King2dBridgeGateway=$(cat deployments/sepolia/King2dBridgeGateway.json | grep "address" -m1 |  awk -F'["]' '{print $4}')

yarn hardhat orivium-o-ft-adapter:set-peer --dst-eid 40231 --peer-address $OriviumOFT --network sepolia
yarn hardhat orivium-o-ft:set-peer --dst-eid 40161 --peer-address $OriviumOFTAdapter --network arbitrumSepolia

yarn hardhat king-bridge-gateway:set-peer --dst-eid 40231 --peer-address $KingONFT --network sepolia
yarn hardhat king2d-bridge-gateway:set-peer --dst-eid 40231 --peer-address $King2dONFT --network sepolia
yarn hardhat king-o-nft:set-peer --dst-eid 40161 --peer-address $KingBridgeGateway --network arbitrumSepolia
yarn hardhat king2d-o-nft:set-peer --dst-eid 40161 --peer-address $King2dBridgeGateway --network arbitrumSepolia

# set enforced options

yarn hardhat king2d-o-nft:set-enforced-options --network arbitrumSepolia
yarn hardhat king-o-nft:set-enforced-options --network arbitrumSepolia
yarn hardhat king-bridge-gateway:set-enforced-options --network sepolia
yarn hardhat king2d-bridge-gateway:set-enforced-options --network sepolia

yarn hardhat orivium-o-ft:set-enforced-options --network arbitrumSepolia
yarn hardhat orivium-o-ft-adapter:set-enforced-options --network sepolia