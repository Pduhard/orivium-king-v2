// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, Vm } from "forge-std/Test.sol";

import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

import { AdminRoleZeroAddress } from "../../contracts/ERC721/Storage.sol";
import { ERC721Item, MissingItemMetadata } from "../../contracts/ERC721/ERC721Item.sol";
import { IItem } from "../../contracts/ERC721/IItem.sol";
import { ItemStorage, ItemItemTypeIdOutOfBounds, ItemBuffUnitTagIdOutOfBounds, ItemBuffStatIdOutOfBounds, ItemEffectNameIdOutOfBounds, ItemDataCategoryIdOutOfBounds, ItemDataPowerIdOutOfBounds, ItemDataEffectIdOutOfBounds, ItemDataBuffIdOutOfBounds, ItemTypeNameIdOutOfBounds, ItemTypeImageURIIdOutOfBounds, ItemTypeRarityIdOutOfBounds, ItemTypeItemDataIdOutOfBounds, BadStatLabelRange, BadUnitLabelRange, BadEffectLabelRange, BadNameLabelRange, BadImageURILabelRange, BadRarityLabelRange, BadCategoryLabelRange, BadPowerLabelRange } from "../../contracts/ERC721/ItemStorage.sol";

import { ItemHelper } from "./ItemHelper.sol";
// import "forge-std/console.sol";

contract TestItem is Test, ItemHelper {
	ERC721Item public item;

	function setUp() public {
		initializeStorages();
		item = new ERC721Item(address(metadataStorage));
		metadataStorage.addConsumer(item);
	}

	function testConstructor() public {
		vm.expectRevert(abi.encodeWithSelector(AdminRoleZeroAddress.selector));
		metadataStorage = new ItemStorage(address(0x00));
	}

	function testInitialization() public {
		assertEq(metadataStorage.itemCount(), 4);
	}

	function minimalLnitialize()
		internal
		pure
		returns (
			string[] memory,
			IItem.ItemData[] memory,
			IItem.ItemType[] memory,
			IItem.ItemEffect[] memory,
			IItem.ItemBuff[] memory,
			IItem.Item[] memory
		)
	{
		string[] memory labels = new string[](8);
		labels[0] = "stat0";
		labels[1] = "unitTag0";
		labels[2] = "effectName0";
		labels[3] = "itemName0";
		labels[4] = "imageURI0";
		labels[5] = "rarity0";
		labels[6] = "category0";
		labels[7] = "power0";

		IItem.ItemData[] memory itemDatas = new IItem.ItemData[](1);
		IItem.ItemType[] memory itemTypes = new IItem.ItemType[](1);
		IItem.ItemEffect[] memory itemEffects = new IItem.ItemEffect[](1);
		IItem.ItemBuff[] memory itemBuffs = new IItem.ItemBuff[](1);
		IItem.Item[] memory items = new IItem.Item[](1);

		itemEffects[0].nameId = 0;

		itemBuffs[0].statId = 0;
		itemBuffs[0].unitTagId = 0;

		itemDatas[0].categoryId = 0;
		itemDatas[0].powerId = 0;
		itemDatas[0].effectIds[0] = 0;
		itemDatas[0].effectIds[1] = 65535;
		itemDatas[0].buffIds[0] = 0;
		itemDatas[0].buffIds[1] = 65535;

		itemTypes[0].nameId = 0;
		itemTypes[0].imageURIId = 0;
		itemTypes[0].rarityId = 0;
		itemTypes[0].itemDataId = 0;

		items[0].itemTypeId = 0;

		return (labels, itemDatas, itemTypes, itemEffects, itemBuffs, items);
	}

	function testUpdateMetadataItemEffectNameIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemEffects[0].nameId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemEffectNameIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemBuffStatIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemBuffs[0].statId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemBuffStatIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemBuffUnitTagIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemBuffs[0].unitTagId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemBuffUnitTagIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemDataCategoryIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemDatas[0].categoryId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemDataCategoryIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemDataPowerIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemDatas[0].powerId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemDataPowerIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemDataEffectIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemDatas[0].effectIds[0] = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemDataEffectIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemDataBuffIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemDatas[0].buffIds[0] = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemDataBuffIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemTypeNameIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemTypes[0].nameId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemTypeNameIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemTypeImageURIIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemTypes[0].imageURIId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemTypeImageURIIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemTypeRarityIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemTypes[0].rarityId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemTypeRarityIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemTypeItemDataIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		itemTypes[0].itemDataId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemTypeItemDataIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataItemItemTypeIdOutOfBounds() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();

		items[0].itemTypeId = 1;
		vm.expectRevert(abi.encodeWithSelector(ItemItemTypeIdOutOfBounds.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadStatLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadStatLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 1, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadStatLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadStatLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 2 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}
	function testUpdateMetadataBadUnitLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadUnitLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 0 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadUnitLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadUnitLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 3 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadEffectLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadEffectLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 1 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadEffectLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadEffectLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 4 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadNameLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadNameLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 2 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadNameLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadNameLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 5 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadImageURILabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadImageURILabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 3 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadImageURILabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadImageURILabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 6 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadRarityLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadRarityLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 4 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadRarityLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadRarityLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 7 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadCategoryLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadCategoryLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 5 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadCategoryLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadCategoryLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 8 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadPowerLabelRange1() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadPowerLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 6 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataBadPowerLabelRange2() public {
		(
			string[] memory labels,
			IItem.ItemData[] memory itemDatas,
			IItem.ItemType[] memory itemTypes,
			IItem.ItemEffect[] memory itemEffects,
			IItem.ItemBuff[] memory itemBuffs,
			IItem.Item[] memory items
		) = minimalLnitialize();
		vm.expectRevert(abi.encodeWithSelector(BadPowerLabelRange.selector));
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 9 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
	}

	function testUpdateMetadataWithBigDataset() public {
		// latest gas usage: 470,257,436
		updateSorageWithBigDataset();
	}

	function testGetItemView() public {
		IItem.ItemView memory itemView = item.getItemView(2);

		assertEq(itemView.name, "itemName1");
		assertEq(itemView.imageURI, "imageURI1");
		assertEq(itemView.category, "category1");
		assertEq(itemView.rarity, "rarity1");
		assertEq(itemView.power, "power1");
		assertEq(itemView.buffs.length, 2);
		assertEq(itemView.effects.length, 2);

		assertEq(itemView.buffs[0].stat, "stat2");
		assertEq(itemView.buffs[0].unitTag, "unitTag2");
		assertEq(itemView.buffs[0].isFlat, false);
		assertEq(itemView.buffs[0].multiplier, 2);

		assertEq(itemView.buffs[1].stat, "stat3");
		assertEq(itemView.buffs[1].unitTag, "unitTag3");
		assertEq(itemView.buffs[1].isFlat, false);
		assertEq(itemView.buffs[1].multiplier, 2);

		assertEq(itemView.effects[0].name, "effectName2");
		assertEq(itemView.effects[0].multiplier, 2);

		assertEq(itemView.effects[1].name, "effectName3");
		assertEq(itemView.effects[1].multiplier, 2);
	}

	function testMint() public {
		item.mint(address(this), 2);
		assertEq(item.balanceOf(address(this)), 1);
		assertEq(item.ownerOf(2), address(this));
	}

	function testMintWithMissingMetadata() public {
		vm.expectRevert(abi.encodeWithSelector(MissingItemMetadata.selector));
		item.mint(address(this), 999);
	}

	function testMintWithMissingMetadataEdge() public {
		item.mint(address(this), 4);

		vm.expectRevert(abi.encodeWithSelector(MissingItemMetadata.selector));
		item.mint(address(this), 5);
	}

	function testBurn() public {
		item.mint(address(this), 2);
		item.burn(2);
		assertEq(item.balanceOf(address(this)), 0);
	}

	function testMintWithMetadata() public {
		uint256 itemCount = metadataStorage.itemCount();
		IItem.Item memory newItem = IItem.Item({ itemTypeId: 2, bonus: 23 });
		item.mintWithMetadata(address(this), newItem);

		assertEq(item.balanceOf(address(this)), 1);
		assertEq(item.ownerOf(itemCount + 1), address(this));
		assertEq(metadataStorage.itemCount(), itemCount + 1);
	}

	function testMintWithMetadataWihleFullyMinted() public {
		uint256 itemCount = metadataStorage.itemCount();
		for (uint256 i = 0; i < itemCount; i++) {
			item.mint(address(this), i + 1);
		}
		IItem.Item memory newItem = IItem.Item({ itemTypeId: 2, bonus: 23 });
		item.mintWithMetadata(address(this), newItem);

		assertEq(metadataStorage.itemCount(), itemCount + 1);
		assertEq(item.ownerOf(itemCount + 1), address(this));
	}

	function testMintWithMetadataWithBadItemTypeId() public {
		uint256 itemCount = metadataStorage.itemCount();
		for (uint256 i = 0; i < itemCount; i++) {
			item.mint(address(this), i + 1);
		}
		IItem.Item memory newItem = IItem.Item({ itemTypeId: 8, bonus: 23 });

		vm.expectRevert(abi.encodeWithSelector(ItemItemTypeIdOutOfBounds.selector));
		item.mintWithMetadata(address(this), newItem);
	}

	function testTokenURI() public {
		item.mint(address(this), 1);
		string memory uri = item.tokenURI(1);

		string memory expectedURI = string(
			abi.encodePacked(
				"data:application/json;base64,",
				Base64.encode(
					abi.encodePacked(
						'{"name":"Orivium Item #1","description":"Orivium Item","image":"imageURI0","attributes":[{"trait_type":"Rarity","value":"rarity0"},{"trait_type":"Category","value":"category0"},{"trait_type":"Power","value":"power0"}],"effects":[],"buffs":[]}'
					)
				)
			)
		);
		assertEq(uri, expectedURI);
		// console.log(uri);
	}

	function testTokenURINotMinted() public {
		vm.expectRevert("ERC721: invalid token ID");
		item.tokenURI(999);
	}

	function testGetItemCategoryId() public {
		assertEq(item.getItemCategoryId(1), 0);
		assertEq(item.getItemCategoryId(2), 1);
		assertEq(item.getItemCategoryId(3), 2);
	}

	function testMetadataUpdateEvent() public {
		string[] memory labels = new string[](8);
		labels[0] = "stat0";
		labels[1] = "unitTag0";
		labels[2] = "effectName0";
		labels[3] = "itemName0";
		labels[4] = "imageURI0";
		labels[5] = "rarity0";
		labels[6] = "category0";
		labels[7] = "power0";

		IItem.ItemData[] memory itemDatas = new IItem.ItemData[](1);
		IItem.ItemType[] memory itemTypes = new IItem.ItemType[](1);
		IItem.ItemEffect[] memory itemEffects = new IItem.ItemEffect[](1);
		IItem.ItemBuff[] memory itemBuffs = new IItem.ItemBuff[](1);
		IItem.Item[] memory items = new IItem.Item[](1);

		itemBuffs[0].statId = 0;
		itemBuffs[0].unitTagId = 0;

		itemEffects[0].nameId = 0;

		itemTypes[0].nameId = 0;
		itemTypes[0].imageURIId = 0;
		itemTypes[0].rarityId = 0;
		itemTypes[0].itemDataId = 0;

		itemDatas[0].categoryId = 0;
		itemDatas[0].powerId = 0;
		itemDatas[0].effectIds[0] = 0;
		itemDatas[0].effectIds[1] = 65535;
		itemDatas[0].buffIds[0] = 0;
		itemDatas[0].buffIds[1] = 65535;

		items[0].itemTypeId = 0;

		item.mint(address(this), 1);

		vm.recordLogs();
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);
		Vm.Log[] memory entries = vm.getRecordedLogs();

		assertEq(entries.length, 1);
		assertEq(entries[0].topics.length, 1);
		(uint256 from, uint256 to) = abi.decode(entries[0].data, (uint256, uint256));
		assertEq(entries[0].topics[0], IERC4906.BatchMetadataUpdate.selector);
		assertEq(from, uint256(1));
		assertEq(to, uint256(1));

		vm.recordLogs();
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);

		entries = vm.getRecordedLogs();
		assertEq(entries.length, 1);
		assertEq(entries[0].topics.length, 1);
		(from, to) = abi.decode(entries[0].data, (uint256, uint256));
		assertEq(entries[0].topics[0], IERC4906.BatchMetadataUpdate.selector);
		assertEq(from, uint256(1));
		assertEq(to, uint256(1));

		vm.recordLogs();
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);

		entries = vm.getRecordedLogs();
		assertEq(entries.length, 1);
		assertEq(entries[0].topics.length, 1);
		(from, to) = abi.decode(entries[0].data, (uint256, uint256));
		assertEq(entries[0].topics[0], IERC4906.BatchMetadataUpdate.selector);
		assertEq(from, uint256(1));

		vm.recordLogs();
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);

		entries = vm.getRecordedLogs();
		assertEq(entries.length, 1);
		assertEq(entries[0].topics.length, 1);
		(from, to) = abi.decode(entries[0].data, (uint256, uint256));
		assertEq(entries[0].topics[0], IERC4906.BatchMetadataUpdate.selector);
		assertEq(from, uint256(1));

		vm.recordLogs();
		metadataStorage.updateMetadata(
			labels,
			ItemStorage.LabelStoreRanges({
				stat: ItemStorage.LabelStoreRange({ from: 0, to: 1 }),
				unit: ItemStorage.LabelStoreRange({ from: 1, to: 2 }),
				effect: ItemStorage.LabelStoreRange({ from: 2, to: 3 }),
				name: ItemStorage.LabelStoreRange({ from: 3, to: 4 }),
				imageURI: ItemStorage.LabelStoreRange({ from: 4, to: 5 }),
				rarity: ItemStorage.LabelStoreRange({ from: 5, to: 6 }),
				category: ItemStorage.LabelStoreRange({ from: 6, to: 7 }),
				power: ItemStorage.LabelStoreRange({ from: 7, to: 8 })
			}),
			itemBuffs,
			itemEffects,
			itemDatas,
			itemTypes,
			items
		);

		entries = vm.getRecordedLogs();
		assertEq(entries.length, 1);
		assertEq(entries[0].topics.length, 1);
		(from, to) = abi.decode(entries[0].data, (uint256, uint256));
		assertEq(entries[0].topics[0], IERC4906.BatchMetadataUpdate.selector);
		assertEq(from, uint256(1));
	}
}
