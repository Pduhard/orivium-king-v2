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

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ItemStorage } from "./ItemStorage.sol";
import { IStorageConsumer } from "./IStorageConsumer.sol";
import { IItem } from "./IItem.sol";

error ItemStorageZeroAddress();
error MissingItemMetadata();

contract ERC721Item is IItem, IStorageConsumer, IERC4906, ERC721Enumerable {
	using Strings for uint256;

	ItemStorage public immutable ITEM_STORAGE;

	constructor(address _itemStorage) ERC721("Item", "KINGSTUFF") {
		if (_itemStorage == address(0)) {
			revert ItemStorageZeroAddress();
		}
		ITEM_STORAGE = ItemStorage(_itemStorage);
	}

	function mint(address _to, uint256 _tokenId) external {
		// TODO: add roles
		if (_tokenId == 0 || _tokenId > ITEM_STORAGE.itemCount()) {
			revert MissingItemMetadata();
		}
		_mint(_to, _tokenId);
	}

	function burn(uint256 _tokenId) external {
		// TODO: add roles
		_burn(_tokenId);
	}

	function mintWithMetadata(address _to, IItem.Item memory _item) external {
		// TODO: add roles
		ITEM_STORAGE.addItem(_item);
		_mint(_to, ITEM_STORAGE.itemCount());
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		// TODO: need an adapter / codec
		_requireMinted(_tokenId);
		IItem.ItemView memory itemView = ITEM_STORAGE.getItemView(_tokenId);

		// prettier-ignore
		return string(abi.encodePacked("data:application/json;base64,", Base64.encode(abi.encodePacked(
			"{",
				'"name":"Orivium Item #', _tokenId.toString(), '",',
				'"description":"Orivium Item",',
				'"image":"', itemView.imageURI, '",',
				'"attributes":[',
					'{"trait_type":"Rarity","value":"', itemView.rarity, '"},'
					'{"trait_type":"Category","value":"', itemView.category, '"},'
					'{"trait_type":"Power","value":"', itemView.power, '"}'
				'],',
				'"effects":[],',
				'"buffs":[]',
			"}"
		))));
	}

	/*********************************************
	 *                  UTILS                    *
	 ********************************************/

	function getItem(uint256 _tokenId) external view returns (Item memory) {
		return ITEM_STORAGE.getItem(_tokenId);
	}

	function getItemView(uint256 _tokenId) external view returns (ItemView memory) {
		return ITEM_STORAGE.getItemView(_tokenId);
	}

	function getItemCategoryId(uint256 _tokenId) external view returns (uint256) {
		return ITEM_STORAGE.getItemCategoryId(_tokenId);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
		return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
	}

	function onStorageUpdate() external override {
		emit BatchMetadataUpdate(1, totalSupply());
	}
}
