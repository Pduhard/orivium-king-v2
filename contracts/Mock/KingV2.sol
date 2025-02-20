// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { KingV2 } from "../ERC721/KingV2.sol";

contract KingV2Mock is KingV2 {
	constructor(address _itemAddress) KingV2(_itemAddress) {
		mint(msg.sender, 0);
		mint(msg.sender, 1);
		mint(msg.sender, 2);
		mint(msg.sender, 3);
	}

	function mint(address to, uint256 tokenId) public {
		_mint(to, tokenId);
	}
}
