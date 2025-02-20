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

import { IItem } from "./IItem.sol";
import { Storage } from "./Storage.sol";

// import "forge-std/console.sol";

error ItemTypeStorageZeroAddress();

error ItemItemTypeIdOutOfBounds();

error ItemBuffStatIdOutOfBounds();
error ItemBuffUnitTagIdOutOfBounds();

error ItemEffectNameIdOutOfBounds();

error ItemTypeNameIdOutOfBounds();
error ItemTypeImageURIIdOutOfBounds();
error ItemTypeRarityIdOutOfBounds();
error ItemTypeItemDataIdOutOfBounds();

error ItemDataCategoryIdOutOfBounds();
error ItemDataPowerIdOutOfBounds();
error ItemDataEffectIdOutOfBounds();
error ItemDataBuffIdOutOfBounds();

error BadStatLabelRange();
error BadUnitLabelRange();
error BadEffectLabelRange();
error BadNameLabelRange();
error BadImageURILabelRange();
error BadRarityLabelRange();
error BadCategoryLabelRange();
error BadPowerLabelRange();

contract ItemStorage is Storage {
	struct LabelStoreRange {
		uint256 from;
		uint256 to;
	}

	struct LabelStoreRanges {
		LabelStoreRange stat;
		LabelStoreRange unit;
		LabelStoreRange effect;
		LabelStoreRange name;
		LabelStoreRange imageURI;
		LabelStoreRange rarity;
		LabelStoreRange category;
		LabelStoreRange power;
	}

	LabelStoreRanges private labelStoreRanges;

	mapping(uint256 => string) private labels;

	/// @dev mapping between token id and Item structure (from 1 to itemCount inclusive)
	mapping(uint256 => IItem.Item) private items;
	uint256 public itemCount;

	/// @dev mapping between item data id and ItemBuff structure (id from 0 to itemBuffCount - 1)
	mapping(uint256 => IItem.ItemBuff) private itemBuffs;
	uint256 private itemBuffCount;

	/// @dev mapping between item effect id and ItemEffect structure (id from 0 to itemEffectCount - 1)
	mapping(uint256 => IItem.ItemEffect) private itemEffects;
	uint256 private itemEffectCount;

	/// @dev mapping between item data id and ItemData structure (id from 0 to itemDataCount - 1)
	mapping(uint256 => IItem.ItemData) private itemDatas;
	uint256 private itemDataCount;

	/// @dev mapping between item data id and ItemType structure (id from 0 to itemTypeCount - 1)
	mapping(uint256 => IItem.ItemType) private itemTypes;
	uint256 private itemTypeCount;

	constructor(address _adminRole) Storage(_adminRole) {}

	function addItem(IItem.Item memory _item) external {
		// TODO: add roles
		if (_item.itemTypeId >= itemTypeCount) {
			revert ItemItemTypeIdOutOfBounds();
		}
		itemCount++;
		items[itemCount] = _item;
	}

	function getItem(uint256 _itemId) external view returns (IItem.Item memory) {
		return items[_itemId];
	}

	function getItemView(uint256 _itemId) external view returns (IItem.ItemView memory) {
		IItem.Item memory item = items[_itemId];
		IItem.ItemType memory itemType = itemTypes[item.itemTypeId];
		IItem.ItemData memory itemData = itemDatas[itemType.itemDataId];

		uint256 effectCount = 0;
		while (
			effectCount < itemData.effectIds.length && itemData.effectIds[effectCount] != 65535
		) {
			effectCount++;
		}
		uint256 buffCount = 0;
		while (buffCount < itemData.buffIds.length && itemData.buffIds[buffCount] != 65535) {
			buffCount++;
		}
		IItem.ItemEffectView[] memory effects = new IItem.ItemEffectView[](effectCount);
		IItem.ItemBuffView[] memory buffs = new IItem.ItemBuffView[](buffCount);

		for (uint256 i = 0; i < effectCount; i++) {
			IItem.ItemEffect memory itemEffect = itemEffects[itemData.effectIds[i]];

			effects[i] = IItem.ItemEffectView({
				name: labels[labelStoreRanges.effect.from + itemEffect.nameId],
				multiplier: itemEffect.multiplier
			});
		}
		for (uint256 i = 0; i < buffCount; i++) {
			IItem.ItemBuff memory itemBuff = itemBuffs[itemData.buffIds[i]];

			buffs[i] = IItem.ItemBuffView({
				stat: labels[labelStoreRanges.stat.from + itemBuff.statId],
				unitTag: labels[labelStoreRanges.unit.from + itemBuff.unitTagId],
				isFlat: itemBuff.isFlat,
				multiplier: itemBuff.multiplier
			});
		}

		return
			IItem.ItemView({
				bonus: item.bonus,
				name: labels[labelStoreRanges.name.from + itemType.nameId],
				imageURI: labels[labelStoreRanges.imageURI.from + itemType.imageURIId],
				rarity: labels[labelStoreRanges.rarity.from + itemType.rarityId],
				category: labels[labelStoreRanges.category.from + itemData.categoryId],
				power: labels[labelStoreRanges.power.from + itemData.powerId],
				effects: effects,
				buffs: buffs
			});
	}

	function getItemCategoryId(uint256 _itemId) external view returns (uint256) {
		return itemDatas[itemTypes[items[_itemId].itemTypeId].itemDataId].categoryId;
	}

	function updateMetadata(
		string[] memory _labels,
		LabelStoreRanges memory _labelStoreRanges,
		IItem.ItemBuff[] memory _itemBuffs,
		IItem.ItemEffect[] memory _itemEffects,
		IItem.ItemData[] memory _itemDatas,
		IItem.ItemType[] memory _itemTypes,
		IItem.Item[] memory _items
	) external onlyRole(STORAGE_ADMIN_ROLE) {
		// TODO: add roles
		_updateMetadata(
			_labels,
			_labelStoreRanges,
			_itemBuffs,
			_itemEffects,
			_itemDatas,
			_itemTypes,
			_items
		);
	}

	function _updateMetadata(
		string[] memory _labels,
		LabelStoreRanges memory _labelStoreRanges,
		IItem.ItemBuff[] memory _itemBuffs,
		IItem.ItemEffect[] memory _itemEffects,
		IItem.ItemData[] memory _itemDatas,
		IItem.ItemType[] memory _itemTypes,
		IItem.Item[] memory _items
	) internal notifyUpdate {
		if (
			_labelStoreRanges.stat.from != 0 ||
			_labelStoreRanges.stat.to != _labelStoreRanges.unit.from
		) {
			revert BadStatLabelRange();
		}
		if (
			_labelStoreRanges.unit.from >= _labelStoreRanges.unit.to ||
			_labelStoreRanges.unit.to != _labelStoreRanges.effect.from
		) {
			revert BadUnitLabelRange();
		}
		if (
			_labelStoreRanges.effect.from >= _labelStoreRanges.effect.to ||
			_labelStoreRanges.effect.to != _labelStoreRanges.name.from
		) {
			revert BadEffectLabelRange();
		}
		if (
			_labelStoreRanges.name.from >= _labelStoreRanges.name.to ||
			_labelStoreRanges.name.to != _labelStoreRanges.imageURI.from
		) {
			revert BadNameLabelRange();
		}
		if (
			_labelStoreRanges.imageURI.from >= _labelStoreRanges.imageURI.to ||
			_labelStoreRanges.imageURI.to != _labelStoreRanges.rarity.from
		) {
			revert BadImageURILabelRange();
		}
		if (
			_labelStoreRanges.rarity.from >= _labelStoreRanges.rarity.to ||
			_labelStoreRanges.rarity.to != _labelStoreRanges.category.from
		) {
			revert BadRarityLabelRange();
		}
		if (
			_labelStoreRanges.category.from >= _labelStoreRanges.category.to ||
			_labelStoreRanges.category.to != _labelStoreRanges.power.from
		) {
			revert BadCategoryLabelRange();
		}
		if (
			_labelStoreRanges.power.from >= _labelStoreRanges.power.to ||
			_labelStoreRanges.power.to != _labels.length
		) {
			revert BadPowerLabelRange();
		}

		// update label store ranges
		labelStoreRanges = _labelStoreRanges;

		uint256 statCount = labelStoreRanges.stat.to - labelStoreRanges.stat.from;
		uint256 unitCount = labelStoreRanges.unit.to - labelStoreRanges.unit.from;
		uint256 effectCount = labelStoreRanges.effect.to - labelStoreRanges.effect.from;
		uint256 nameCount = labelStoreRanges.name.to - labelStoreRanges.name.from;
		uint256 imageURICount = labelStoreRanges.imageURI.to - labelStoreRanges.imageURI.from;
		uint256 categoryCount = labelStoreRanges.category.to - labelStoreRanges.category.from;
		uint256 rarityCount = labelStoreRanges.rarity.to - labelStoreRanges.rarity.from;
		uint256 powerCount = labelStoreRanges.power.to - labelStoreRanges.power.from;

		for (uint256 i = 0; i < _labels.length; i++) {
			labels[i] = _labels[i];
		}

		// update buffs

		itemBuffCount = _itemBuffs.length;

		for (uint256 i = 0; i < itemBuffCount; i++) {
			if (_itemBuffs[i].statId >= statCount) {
				revert ItemBuffStatIdOutOfBounds();
			}
			if (_itemBuffs[i].unitTagId >= unitCount) {
				revert ItemBuffUnitTagIdOutOfBounds();
			}
			itemBuffs[i] = IItem.ItemBuff(
				_itemBuffs[i].statId,
				_itemBuffs[i].unitTagId,
				_itemBuffs[i].isFlat,
				_itemBuffs[i].multiplier
			);
		}

		// update item effects

		itemEffectCount = _itemEffects.length;
		for (uint256 i = 0; i < itemEffectCount; i++) {
			if (_itemEffects[i].nameId >= effectCount) {
				revert ItemEffectNameIdOutOfBounds();
			}
			itemEffects[i] = IItem.ItemEffect(_itemEffects[i].nameId, _itemEffects[i].multiplier);
		}

		// update item data

		itemDataCount = _itemDatas.length;
		for (uint256 i = 0; i < itemDataCount; i++) {
			if (_itemDatas[i].categoryId >= categoryCount) {
				revert ItemDataCategoryIdOutOfBounds();
			}
			if (_itemDatas[i].powerId >= powerCount) {
				revert ItemDataPowerIdOutOfBounds();
			}
			itemDatas[i].categoryId = _itemDatas[i].categoryId;
			itemDatas[i].powerId = _itemDatas[i].powerId;

			for (uint256 j = 0; j < _itemDatas[i].effectIds.length; j++) {
				itemDatas[i].effectIds[j] = _itemDatas[i].effectIds[j];
				if (_itemDatas[i].effectIds[j] == 65535) break;
				if (_itemDatas[i].effectIds[j] >= itemEffectCount) {
					revert ItemDataEffectIdOutOfBounds();
				}
			}

			for (uint256 j = 0; j < _itemDatas[i].buffIds.length; j++) {
				itemDatas[i].buffIds[j] = _itemDatas[i].buffIds[j];
				if (_itemDatas[i].buffIds[j] == 65535) break;
				if (_itemDatas[i].buffIds[j] >= itemBuffCount) {
					revert ItemDataBuffIdOutOfBounds();
				}
			}
		}

		// update item types

		itemTypeCount = _itemTypes.length;
		for (uint256 i = 0; i < itemTypeCount; i++) {
			if (_itemTypes[i].nameId >= nameCount) {
				revert ItemTypeNameIdOutOfBounds();
			}
			if (_itemTypes[i].imageURIId >= imageURICount) {
				revert ItemTypeImageURIIdOutOfBounds();
			}
			if (_itemTypes[i].rarityId >= rarityCount) {
				revert ItemTypeRarityIdOutOfBounds();
			}
			if (_itemTypes[i].itemDataId >= itemDataCount) {
				revert ItemTypeItemDataIdOutOfBounds();
			}
			itemTypes[i].nameId = _itemTypes[i].nameId;
			itemTypes[i].imageURIId = _itemTypes[i].imageURIId;
			itemTypes[i].rarityId = _itemTypes[i].rarityId;
			itemTypes[i].itemDataId = _itemTypes[i].itemDataId;
		}

		// update items

		itemCount = _items.length;
		for (uint256 i = 0; i < itemCount; i++) {
			if (_items[i].itemTypeId >= itemTypeCount) {
				revert ItemItemTypeIdOutOfBounds();
			}
			items[i + 1] = IItem.Item({ itemTypeId: _items[i].itemTypeId, bonus: _items[i].bonus });
		}
	}
}
