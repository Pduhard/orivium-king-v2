// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract KingMock is ERC721 {
	uint256 public constant TOTAL_SUPPLY = 4444;

	constructor() ERC721("King", "KING") {}

	function mint(address to, uint256 tokenId) public {
		_mint(to, tokenId);
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return "https://nft.orivium.io/nft/king/";
	}

	function walletOfOwner(address _owner) public view returns (uint256[] memory) {
		uint256 tokenCount = balanceOf(_owner);
		uint256 index = 0;
		uint256[] memory tokensId = new uint256[](tokenCount);

		if (tokenCount == 0) return new uint256[](0);

		for (uint256 i = 1; i <= TOTAL_SUPPLY; i += 1) {
			if (_ownerOf(i) != _owner) continue;
			tokensId[index] = i;
			index++;
			if (index == tokenCount) break;
		}

		return tokensId;
	}
}
