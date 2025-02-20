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

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IItem is IERC721 {
	////// DATA STORAGE //////

	/**
	 * @dev ItemEffect data structure containing information about an item effect
	 *
	 * @param nameId: id pointing to the effectNameLabels mapping
	 * @param multiplier: effect multiplier
	 */
	struct ItemEffect {
		uint128 nameId;
		int128 multiplier;
	} // ~256 bits

	/**
	 * @dev ItemBuff data structure containing information about an item buff
	 *
	 * @param statId: id pointing to the statLabels mapping
	 * @param unitTagId: id pointing to the unitTagLabels mapping
	 * @param isFlat: whether the buff is flat or percentage
	 * @param multiplier: buff multiplier
	 */
	struct ItemBuff {
		uint64 statId;
		uint56 unitTagId;
		bool isFlat;
		int128 multiplier;
	} // ~256 bits

	/**
	 * @dev Item data structure containing information about an item
	 * @dev multiple ItemType can point to the same ItemData
	 *
	 * @param nameId: id pointing to the itemNameLabels mapping
	 * @param categoryId: id pointing to the categoryLabels mapping
	 * @param rarityId: id pointing to the rarityLabels mapping
	 * @param powerId: id pointing to the powerLabels mapping
	 * @param effectIds: array of ItemEffect ids
	 * @param buffIds: array of ItemBuff ids
	 */
	struct ItemData {
		uint8 categoryId; // e.g. "Weapon", "Hat", "Earrings"
		uint8 powerId; // e.g. "Low", "Medium", "High", "Signature"
		uint16[4] effectIds; // max 4 effects
		uint16[11] buffIds; // max 11 buff
	} // ~256 bits

	/**
	 * @dev Item type structure containing information about an item type
	 * @dev multiple Item can point to the same ItemType
	 *
	 * @param nameId: id pointing to the itemNameLabels mapping
	 * @param imageURIId: id pointing to the imageUriLabels mapping
	 * @param rarityId: id pointing to the rarityLabels mapping
	 * @param itemDataId: id pointing to the itemData mapping
	 */
	struct ItemType {
		uint56 nameId; // unique
		uint56 imageURIId; // unique
		uint16 rarityId; // e.g. "Common", "Uncommon", "Rare", "Epic", "Legendary"
		uint128 itemDataId;
	} // ~256 bits

	/**
	 * @dev Item instance pointing to an ItemData and containing a bonus value
	 *
	 * @param bonus: bonus value
	 * @param itemTypeId: id pointing to the items mapping
	 */
	struct Item {
		uint128 bonus;
		uint128 itemTypeId;
	} // ~256 bits

	////// DATA REPRESENTATION //////

	/**
	 * @dev ItemBuffView data structure exposing human-readable information about an item buff
	 *
	 * @param stat: stat name
	 * @param unitTag: unit tag name
	 * @param isFlat: whether the buff is flat or percentage
	 * @param multiplier: buff multiplier
	 */
	struct ItemBuffView {
		string stat;
		string unitTag;
		bool isFlat;
		int256 multiplier;
	}

	/**
	 * @dev ItemEffectView data structure exposing human-readable information about an item effect
	 *
	 * @param name: effect name
	 * @param multiplier: effect multiplier
	 */
	struct ItemEffectView {
		string name;
		int256 multiplier;
	}

	/**
	 * @dev ItemDataView data structure exposing human-readable information about an item data
	 * @param category: category name (e.g. "Weapon", "Hat", "Earrings")
	 * @param power: power name (e.g. "Low", "Medium", "High", "Signature")
	 * @param effects: array of ItemEffectView
	 * @param buffs: array of ItemBuffView
	 */
	struct ItemDataView {
		string category;
		string power;
		ItemEffectView[] effects;
		ItemBuffView[] buffs;
	}

	/**
	 * @dev ItemTypeView data structure exposing human-readable information about an item type
	 *
	 * @param name: item name
	 * @param imageURI: IPFS item image URI
	 * @param rarity: rarity name (e.g. "Common", "Uncommon", "Rare", "Epic", "Legendary")
	 * @param category: category name (e.g. "Weapon", "Hat", "Earrings")
	 * @param power: power name (e.g. "Low", "Medium", "High", "Signature")
	 * @param effects: array of ItemEffectView
	 * @param buffs: array of ItemBuffView
	 */
	struct ItemTypeView {
		string name;
		string imageURI;
		string rarity;
		string category;
		string power;
		ItemEffectView[] effects;
		ItemBuffView[] buffs;
	}

	/**
	 * @dev ItemView data structure exposing human-readable information about an item
	 *
	 * @param bonus: bonus value
	 * @param name: item name
	 * @param imageURI: IPFS item image URI
	 * @param rarity: rarity name (e.g. "Common", "Uncommon", "Rare", "Epic", "Legendary")
	 * @param category: category name (e.g. "Weapon", "Hat", "Earrings")
	 * @param power: power name (e.g. "Low", "Medium", "High", "Signature")
	 * @param effects: array of ItemEffectView
	 * @param buffs: array of ItemBuffView
	 */
	struct ItemView {
		uint256 bonus;
		string name;
		string imageURI;
		string rarity;
		string category;
		string power;
		ItemEffectView[] effects;
		ItemBuffView[] buffs;
	}

	// function categoryCount() external view returns (uint256);

	function mint(address _to, uint256 _tokenId) external;

	function getItem(uint256 _tokenId) external view returns (Item memory);

	function getItemView(uint256 _tokenId) external view returns (ItemView memory);

	function getItemCategoryId(uint256 _tokenId) external view returns (uint256);
}
