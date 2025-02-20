// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { KingONFT } from "../ERC721/KingONFT.sol";

contract KingONFTMock is KingONFT {
	constructor(
		address _lzEndpoint,
		address _itemAddress,
		uint256[][] memory _itemIdsToMintOnFirstBridge
	) KingONFT(_lzEndpoint, _itemAddress, _itemIdsToMintOnFirstBridge) {}

	function mint(address to, uint256 tokenId) public {
		_mint(to, tokenId);
	}
}
