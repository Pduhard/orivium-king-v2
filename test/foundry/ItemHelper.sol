// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IItem } from "../../contracts/ERC721/IItem.sol";
import { ItemStorage, ItemTypeStorageZeroAddress, ItemItemTypeIdOutOfBounds } from "../../contracts/ERC721/ItemStorage.sol";

abstract contract ItemHelper {
	ItemStorage public metadataStorage;

	function initializeStorages() public {
		string[] memory labels = new string[](64);
		labels[0] = "stat0";
		labels[1] = "stat1";
		labels[2] = "stat2";
		labels[3] = "stat3";
		labels[4] = "stat4";
		labels[5] = "stat5";
		labels[6] = "stat6";
		labels[7] = "stat7";
		labels[8] = "stat8";
		labels[9] = "stat9";
		labels[10] = "stat10";
		labels[11] = "stat11";
		labels[12] = "stat12";
		labels[13] = "stat13";
		labels[14] = "stat14";
		labels[15] = "stat15";
		labels[16] = "stat16";
		labels[17] = "stat17";
		labels[18] = "stat18";
		labels[19] = "stat19";
		labels[20] = "stat20";

		labels[21] = "unitTag0";
		labels[22] = "unitTag1";
		labels[23] = "unitTag2";
		labels[24] = "unitTag3";
		labels[25] = "unitTag4";
		labels[26] = "unitTag5";
		labels[27] = "unitTag6";
		labels[28] = "unitTag7";

		labels[29] = "effectName0";
		labels[30] = "effectName1";
		labels[31] = "effectName2";
		labels[32] = "effectName3";
		labels[33] = "effectName4";
		labels[34] = "effectName5";
		labels[35] = "effectName6";
		labels[36] = "effectName7";

		labels[37] = "itemName0";
		labels[38] = "itemName1";
		labels[39] = "itemName2";
		labels[40] = "itemName3";
		labels[41] = "itemName4";
		labels[42] = "itemName5";
		labels[43] = "itemName6";
		labels[44] = "itemName7";

		labels[45] = "imageURI0";
		labels[46] = "imageURI1";
		labels[47] = "imageURI2";
		labels[48] = "imageURI3";
		labels[49] = "imageURI4";
		labels[50] = "imageURI5";
		labels[51] = "imageURI6";
		labels[52] = "imageURI7";

		labels[53] = "rarity0";
		labels[54] = "rarity1";
		labels[55] = "rarity2";
		labels[56] = "rarity3";

		labels[57] = "category0";
		labels[58] = "category1";
		labels[59] = "category2";

		labels[60] = "power0";
		labels[61] = "power1";
		labels[62] = "power2";
		labels[63] = "power3";

		IItem.ItemData[] memory itemDatas = new IItem.ItemData[](4);
		IItem.ItemType[] memory itemTypes = new IItem.ItemType[](8);
		IItem.ItemEffect[] memory itemEffects = new IItem.ItemEffect[](4);
		IItem.ItemBuff[] memory itemBuffs = new IItem.ItemBuff[](4);

		IItem.Item[] memory items = new IItem.Item[](4);
		itemEffects[0].nameId = 0;
		itemEffects[0].multiplier = 2;

		itemEffects[1].nameId = 1;
		itemEffects[1].multiplier = 2;

		itemEffects[2].nameId = 2;
		itemEffects[2].multiplier = 2;

		itemEffects[3].nameId = 3;
		itemEffects[3].multiplier = 2;

		itemBuffs[0].statId = 0;
		itemBuffs[0].unitTagId = 0;
		itemBuffs[0].isFlat = false;
		itemBuffs[0].multiplier = 2;

		itemBuffs[1].statId = 1;
		itemBuffs[1].unitTagId = 1;
		itemBuffs[1].isFlat = false;
		itemBuffs[1].multiplier = 2;

		itemBuffs[2].statId = 2;
		itemBuffs[2].unitTagId = 2;
		itemBuffs[2].isFlat = false;
		itemBuffs[2].multiplier = 2;

		itemBuffs[3].statId = 3;
		itemBuffs[3].unitTagId = 3;
		itemBuffs[3].isFlat = false;
		itemBuffs[3].multiplier = 2;

		itemDatas[0].categoryId = 0;
		itemDatas[0].powerId = 0;
		itemDatas[0].effectIds[0] = 0;
		itemDatas[0].effectIds[1] = 1;
		itemDatas[0].effectIds[2] = 65535;
		itemDatas[0].buffIds[0] = 0;
		itemDatas[0].buffIds[1] = 1;
		itemDatas[0].buffIds[2] = 65535;

		itemDatas[1].categoryId = 1;
		itemDatas[1].powerId = 1;
		itemDatas[1].effectIds[0] = 2;
		itemDatas[1].effectIds[1] = 3;
		itemDatas[1].effectIds[2] = 65535;
		itemDatas[1].buffIds[0] = 2;
		itemDatas[1].buffIds[1] = 3;
		itemDatas[1].buffIds[2] = 65535;

		itemDatas[2].categoryId = 2;
		itemDatas[2].powerId = 2;
		itemDatas[2].effectIds[0] = 0;
		itemDatas[2].effectIds[1] = 1;
		itemDatas[2].effectIds[2] = 65535;
		itemDatas[2].buffIds[0] = 0;
		itemDatas[2].buffIds[1] = 1;
		itemDatas[2].buffIds[2] = 65535;

		itemDatas[3].categoryId = 0;
		itemDatas[3].powerId = 3;
		itemDatas[3].effectIds[0] = 2;
		itemDatas[3].effectIds[1] = 3;
		itemDatas[3].effectIds[2] = 65535;
		itemDatas[3].buffIds[0] = 2;
		itemDatas[3].buffIds[1] = 3;
		itemDatas[3].buffIds[2] = 65535;

		itemTypes[0].nameId = 0;
		itemTypes[0].imageURIId = 0;
		itemTypes[0].rarityId = 0;
		itemTypes[0].itemDataId = 0;

		itemTypes[1].nameId = 1;
		itemTypes[1].imageURIId = 1;
		itemTypes[1].rarityId = 1;
		itemTypes[1].itemDataId = 1;

		itemTypes[2].nameId = 2;
		itemTypes[2].imageURIId = 2;
		itemTypes[2].rarityId = 2;
		itemTypes[2].itemDataId = 2;

		itemTypes[3].nameId = 3;
		itemTypes[3].imageURIId = 3;
		itemTypes[3].rarityId = 3;
		itemTypes[3].itemDataId = 3;

		itemTypes[4].nameId = 4;
		itemTypes[4].imageURIId = 4;
		itemTypes[4].rarityId = 0;
		itemTypes[4].itemDataId = 0;

		itemTypes[5].nameId = 5;
		itemTypes[5].imageURIId = 5;
		itemTypes[5].rarityId = 1;
		itemTypes[5].itemDataId = 1;

		itemTypes[6].nameId = 6;
		itemTypes[6].imageURIId = 6;
		itemTypes[6].rarityId = 2;
		itemTypes[6].itemDataId = 2;

		itemTypes[7].nameId = 7;
		itemTypes[7].imageURIId = 7;
		itemTypes[7].rarityId = 3;
		itemTypes[7].itemDataId = 3;

		items[0].itemTypeId = 0;
		items[0].bonus = 23;

		items[1].itemTypeId = 1;
		items[1].bonus = 23;

		items[2].itemTypeId = 2;
		items[2].bonus = 23;

		items[3].itemTypeId = 3;
		items[3].bonus = 23;

		metadataStorage = new ItemStorage(address(address(this)));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 21 }),
				unit: ItemStorage.LabelStoreRange({ from: 21, to: 29 }),
				effect: ItemStorage.LabelStoreRange({ from: 29, to: 37 }),
				name: ItemStorage.LabelStoreRange({ from: 37, to: 45 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 45, to: 53 }),
				rarity: ItemStorage.LabelStoreRange({ from: 53, to: 57 }),
				category: ItemStorage.LabelStoreRange({ from: 57, to: 60 }),
				power: ItemStorage.LabelStoreRange({ from: 60, to: 64 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function updateSorageWithBigDataset() public {
		// latest gas usage: 470,257,436
		// note this included the data generation so it's not accurate
		string[] memory labels = new string[](4099);
		for (uint256 i = 0; i < 21; i++) {
			labels[i] = string(abi.encodePacked("stat", i));
		}

		for (uint256 i = 0; i < 15; i++) {
			labels[21 + i] = string(abi.encodePacked("unitTag", i));
		}

		for (uint256 i = 0; i < 50; i++) {
			labels[36 + i] = string(abi.encodePacked("effectName", i));
		}

		for (uint256 i = 0; i < 2000; i++) {
			labels[86 + i] = string(abi.encodePacked("itemName", i));
		}

		for (uint256 i = 0; i < 2000; i++) {
			labels[2086 + i] = string(abi.encodePacked("imageURI", i));
		}

		for (uint256 i = 0; i < 5; i++) {
			labels[4086 + i] = string(abi.encodePacked("rarity", i));
		}

		for (uint256 i = 0; i < 6; i++) {
			labels[4091 + i] = string(abi.encodePacked("category", i));
		}

		for (uint256 i = 0; i < 2; i++) {
			labels[4097 + i] = string(abi.encodePacked("power", i));
		}

		IItem.ItemEffect[] memory itemEffects = new IItem.ItemEffect[](70);
		for (uint256 i = 0; i < 70; i++) {
			itemEffects[i].nameId = uint128(i % 50);
			itemEffects[i].multiplier = 2;
		}

		IItem.ItemBuff[] memory itemBuffs = new IItem.ItemBuff[](110);
		for (uint256 i = 0; i < 110; i++) {
			itemBuffs[i].statId = uint64(i % 21);
			itemBuffs[i].unitTagId = uint56(i % 15);
			itemBuffs[i].isFlat = false;
			itemBuffs[i].multiplier = 2;
		}

		IItem.ItemData[] memory itemDatas = new IItem.ItemData[](400);
		for (uint256 i = 0; i < 400; i++) {
			itemDatas[i].categoryId = uint8(i % 6);
			itemDatas[i].powerId = uint8(i % 2);
			itemDatas[i].effectIds[0] = uint16(i % 70);
			itemDatas[i].effectIds[1] = uint16((i + 1) % 70);
			itemDatas[i].effectIds[2] = uint16((i + 2) % 70);
			itemDatas[i].effectIds[3] = 65535;

			itemDatas[i].buffIds[0] = uint16(i % 110);
			itemDatas[i].buffIds[1] = uint16((i + 1) % 110);
			itemDatas[i].buffIds[2] = uint16((i + 2) % 110);
			itemDatas[i].buffIds[3] = 65535;
		}

		IItem.ItemType[] memory itemTypes = new IItem.ItemType[](2000);
		for (uint256 i = 0; i < 2000; i++) {
			itemTypes[i].nameId = uint56(i);
			itemTypes[i].imageURIId = uint56(i);
			itemTypes[i].rarityId = uint16(i % 5);
			itemTypes[i].itemDataId = uint128(i % 400);
		}

		IItem.Item[] memory items = new IItem.Item[](4000);
		for (uint256 i = 0; i < 4000; i++) {
			items[i].itemTypeId = uint128(i % 2000);
			items[i].bonus = 23;
		}

		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 21 }),
				unit: ItemStorage.LabelStoreRange({ from: 21, to: 36 }),
				effect: ItemStorage.LabelStoreRange({ from: 36, to: 86 }),
				name: ItemStorage.LabelStoreRange({ from: 86, to: 2086 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 2086, to: 4086 }),
				rarity: ItemStorage.LabelStoreRange({ from: 4086, to: 4091 }),
				category: ItemStorage.LabelStoreRange({ from: 4091, to: 4097 }),
				power: ItemStorage.LabelStoreRange({ from: 4097, to: 4099 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}
}
