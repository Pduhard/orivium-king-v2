// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { King2dONFT } from "../ERC721/King2dONFT.sol";

contract King2dONFTMock is King2dONFT {
	constructor(address _lzEndpoint, address _rewardToken) King2dONFT(_lzEndpoint, _rewardToken) {}

	function mint(address to, uint256 tokenId) public {
		_mint(to, tokenId);
	}
}
