// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/***********************************************************************************************
 *               ...                                                                           *
 *         *@@@@@@@@@@@-                    .                                                  *
 *      .@@@@@@@@@@@@@@@@#                =@@@*             :@@@@                              *
 *     *@@@@@@*.   :*@@@@@@               .@@@.              @@@:                              *
 *    :@@@@@:         =@@@@@                                                                   *
 *    @@@@@:           .@@@@* %@@#@@@@@@= .@@@: @@@     #@@= @@@: @@@     :@@@ @@@%     +%@+   *
 *   .@@@@#             @@@@@ @@@@@@@@@@@@.@@@+ @@@+   -@@@ .@@@= @@@     -@@@ @@@@*   *@@@#   *
 *   .@@@@=             @@@@@.@@@@     @@@+@@@+ =@@@   @@@= .@@@=.@@@.    -@@@.@@@@@. =@@@@*   *
 *   .@@@@#             @@@@@.@@@=.   :@@@+@@@=  @@@- =@@@  .@@@=.@@@.    -@@@.@@@@@@.@@@@@-   *
 *    @@@@@.           .@@@@@.@@@=@@@@@@@*.@@@-  #@@%.@@@:  .@@@: @@@:    =@@@.@@@@@@@@@@@@-   *
 *    .@@@@@.         :@@@@@- @@@::@@@@*  .@@@-  :@@@#@@%   .@@@. #@@@.  :@@@@.@@@*%@@@@@@@-   *
 *     +@@@@@@*:  .-#@@@@@@-  @@@.  @@@*  .@@@:   @@@@@@.    @@@. .@@@@@@@@@@: @@@* @@# @@@.   *
 *      .@@@@@@@@@@@@@@@@@    -==    ===   ===    :@@@@+     ===    :@@@@@@:   -==.  -  ###    *
 *        .%@@@@@@@@@@@+                                                                       *
 *             -+++:                                                                           *
 *                                                                                             *
 **********************************************************************************************/

import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IItem } from "./IItem.sol";
import { ERC721ItemHolder } from "./ERC721ItemHolder.sol";

error NotApprovedOrOwner(address sender, uint256 tokenId);
error DirectERC721Transfer(address sender);
error NoItemEquipped(uint256 kingId, uint256 itemCategory);

contract KingV2 is ERC721ItemHolder, ReentrancyGuard {
	using Strings for uint256;

	uint256 public constant TOTAL_SUPPLY = 4444;

	/// @dev kingId => itemCategory => stuffId
	mapping(uint256 => mapping(uint256 => uint256)) public equippedItems;
	mapping(uint256 => uint256) public equippedItemsCounts;

	constructor(address _itemAddress) ERC721ItemHolder(_itemAddress) ERC721("King", "KING") {}

	function onStorageUpdate() external override {
		emit BatchMetadataUpdate(1, TOTAL_SUPPLY);
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		// prettier-ignore
		return string(abi.encodePacked("data:application/json;base64,", Base64.encode(abi.encodePacked(
			'{',
				'"name":"Orivium King #', _tokenId.toString(), '",',
				'"description":"Orivium King",',
				'"image":"https://nft.orivium.io/nft/king/', _tokenId.toString(), '/image",',
				'"attributes":[',
					getEquippedItemsMetadata(_tokenId),
				']',
			'}'
		))));
	}

	function getEquippedItemsMetadata(uint256 _tokenId) internal view returns (string memory) {
		string memory equippedItemsMetadata = "";
		uint256 categoryCount = 3;
		// uint256 categoryCount = IItem(ITEM).categoryCount(); // fix me

		for (uint256 categoryId = 0; categoryId < categoryCount; categoryId++) {
			uint256 itemId = equippedItems[_tokenId][categoryId];
			if (itemId == 0) continue;

			IItem.ItemView memory itemView = IItem(ITEM).getItemView(itemId);

			// prettier-ignore
			equippedItemsMetadata = string(abi.encodePacked(
				equippedItemsMetadata, bytes(equippedItemsMetadata).length > 0 ? "," : "",
				'{"trait_type":"', itemView.category, '","value":"', itemView.rarity, '"}'
			));
		}
		return equippedItemsMetadata;
	}

	/*********************************************
	 *                  UTILS                    *
	 ********************************************/

	function walletOfOwner(address _owner) external view returns (uint256[] memory) {
		uint256 tokenCount = balanceOf(_owner);
		uint256[] memory tokensId = new uint256[](balanceOf(_owner));
		for (uint256 i = 0; i < tokenCount; i++) {
			tokensId[i] = tokenOfOwnerByIndex(_owner, i);
		}
		return tokensId;
	}

	function equipItem(uint256 _kingTokenId, uint256 _itemTokenId) external nonReentrant {
		_equipItem(_kingTokenId, _itemTokenId);
		emit MetadataUpdate(_kingTokenId);
	}

	function unequipItem(uint256 _kingTokenId, uint8 _itemCategory) external nonReentrant {
		_unequipItem(_kingTokenId, _itemCategory);
		emit MetadataUpdate(_kingTokenId);
	}

	function _equipItem(uint256 _kingTokenId, uint256 _itemTokenId) internal {
		// TODO: add roles
		if (!_isApprovedOrOwner(_msgSender(), _kingTokenId))
			revert NotApprovedOrOwner(_msgSender(), _kingTokenId);

		address kingOwner = ownerOf(_kingTokenId);
		IItem(ITEM).safeTransferFrom(kingOwner, address(this), _itemTokenId);

		uint256 itemCategoryId = IItem(ITEM).getItemCategoryId(_itemTokenId);
		if (equippedItems[_kingTokenId][itemCategoryId] != 0) {
			_unequipItem(_kingTokenId, itemCategoryId);
		}

		equippedItems[_kingTokenId][itemCategoryId] = _itemTokenId;
	}

	function _unequipItem(uint256 _kingTokenId, uint256 _itemCategory) internal {
		if (!_isApprovedOrOwner(_msgSender(), _kingTokenId))
			revert NotApprovedOrOwner(_msgSender(), _kingTokenId);

		uint256 stuffId = equippedItems[_kingTokenId][_itemCategory];
		if (stuffId == 0) revert NoItemEquipped(_kingTokenId, _itemCategory);

		equippedItems[_kingTokenId][_itemCategory] = 0;

		address kingOwner = ownerOf(_kingTokenId);
		IItem(ITEM).safeTransferFrom(address(this), kingOwner, stuffId);
	}

	function onERC721Received(
		address _operator,
		address,
		uint256,
		bytes calldata
	) external view override returns (bytes4) {
		if (_operator != address(this)) revert DirectERC721Transfer(_operator);
		return this.onERC721Received.selector;
	}
}
