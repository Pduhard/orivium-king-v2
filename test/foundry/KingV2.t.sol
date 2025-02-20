// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, Vm } from "forge-std/Test.sol";
import { IERC4906 } from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { NotApprovedOrOwner, NoItemEquipped, DirectERC721Transfer } from "../../contracts/ERC721/KingV2.sol";
import { KingV2Mock } from "../../contracts/Mock/KingV2.sol";
import { ERC721Item } from "../../contracts/ERC721/ERC721Item.sol";
import { ItemAddressIsZeroAddress } from "../../contracts/ERC721/ERC721ItemHolder.sol";
import { ItemHelper } from "./ItemHelper.sol";

// import "forge-std/console.sol";

contract TestKingV2 is Test, ItemHelper, IERC721Receiver {
	using Strings for uint256;

	KingV2Mock public king;
	ERC721Item public item;

	address public userA = address(0x1);
	address public userB = address(0x2);

	function setUp() public {
		vm.deal(userA, 1000 ether);
		vm.deal(userB, 1000 ether);

		initializeStorages();
		item = new ERC721Item(address(metadataStorage));
		king = new KingV2Mock(address(item));
	}

	function testConstructor() public {
		vm.expectRevert(ItemAddressIsZeroAddress.selector);
		king = new KingV2Mock(address(0));
	}

	function testItemAddress() public {
		assertEq(address(item), address(king.ITEM()));
	}

	function testEquipItem() public {
		item.mint(address(this), 1);
		item.mint(address(this), 2);
		item.mint(address(this), 3);
		king.mint(address(this), 23);

		item.approve(address(king), 1);
		item.approve(address(king), 2);
		item.approve(address(king), 3);
		king.equipItem(23, 1);
		king.equipItem(23, 2);
		king.equipItem(23, 3);

		assertEq(item.ownerOf(1), address(king));
		assertEq(item.ownerOf(2), address(king));
		assertEq(item.ownerOf(3), address(king));
		assertEq(king.equippedItems(23, 0), 1);
		assertEq(king.equippedItems(23, 1), 2);
		assertEq(king.equippedItems(23, 2), 3);
	}

	function testEquipItemNotOwner() public {
		item.mint(userA, 1);
		king.mint(address(this), 23);

		vm.prank(userA);
		item.approve(address(king), 1);
		vm.expectRevert("ERC721: transfer from incorrect owner");
		king.equipItem(23, 1);
	}

	function testEquipItemNotOwner2() public {
		item.mint(address(this), 1);
		king.mint(userA, 23);
		item.approve(address(king), 1);

		vm.expectRevert(abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), 23));
		king.equipItem(23, 1);
	}

	function testEquipItemNotOwner3() public {
		item.mint(userA, 1);
		king.mint(userA, 23);
		vm.prank(userA);
		item.approve(address(king), 1);

		vm.expectRevert(abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), 23));
		king.equipItem(23, 1);
	}

	function testEquipItemWhenAlreadyEquipped() public {
		item.mint(address(this), 1);
		item.mint(address(this), 4);
		king.mint(address(this), 23);

		item.approve(address(king), 1);
		item.approve(address(king), 4);

		king.equipItem(23, 1);

		vm.recordLogs();
		king.equipItem(23, 4);
		Vm.Log[] memory entries = vm.getRecordedLogs();

		assertEq(entries.length, 3);
		assertEq(entries[0].topics.length, 4);
		assertEq(entries[0].topics[0], IERC721.Transfer.selector);
		assertEq(entries[0].topics[1], bytes32(uint256(uint160(address(this)))));
		assertEq(entries[0].topics[2], bytes32(uint256(uint160(address(king)))));
		assertEq(entries[0].topics[3], bytes32(uint256(4)));

		assertEq(entries[1].topics.length, 4);
		assertEq(entries[1].topics[0], IERC721.Transfer.selector);
		assertEq(entries[1].topics[1], bytes32(uint256(uint160(address(king)))));
		assertEq(entries[1].topics[2], bytes32(uint256(uint160(address(this)))));
		assertEq(entries[1].topics[3], bytes32(uint256(1)));

		assertEq(entries[2].topics.length, 1);
		assertEq(entries[2].topics[0], IERC4906.MetadataUpdate.selector);
		uint256 tokenId = abi.decode(entries[2].data, (uint256));
		assertEq(tokenId, 23);
		assertEq(item.ownerOf(1), address(this));
		assertEq(item.ownerOf(4), address(king));
		assertEq(king.equippedItems(23, 0), 4);
	}

	function testDirectERC721Transfer() public {
		item.mint(address(this), 1);
		king.mint(address(this), 23);

		vm.expectRevert(abi.encodeWithSelector(DirectERC721Transfer.selector, address(this)));
		item.safeTransferFrom(address(this), address(king), 1);
	}

	function testUnequipItem() public {
		item.mint(address(this), 1);
		item.mint(address(this), 2);
		item.mint(address(this), 3);
		king.mint(address(this), 23);

		item.approve(address(king), 1);
		item.approve(address(king), 2);
		item.approve(address(king), 3);
		king.equipItem(23, 1);
		king.equipItem(23, 2);
		king.equipItem(23, 3);

		king.unequipItem(23, 0);
		king.unequipItem(23, 1);
		king.unequipItem(23, 2);
		assertEq(king.equippedItems(23, 0), 0);
		assertEq(king.equippedItems(23, 1), 0);
		assertEq(king.equippedItems(23, 2), 0);
		assertEq(item.ownerOf(1), address(this));
		assertEq(item.ownerOf(2), address(this));
		assertEq(item.ownerOf(3), address(this));
	}

	function testUnequipItemNotOwner() public {
		item.mint(address(this), 1);
		king.mint(address(this), 23);
		item.approve(address(king), 1);
		king.equipItem(23, 1);

		vm.prank(userA);
		vm.expectRevert(abi.encodeWithSelector(NotApprovedOrOwner.selector, address(userA), 23));
		king.unequipItem(23, 0);
	}

	function testUnequipItemNoItemEquiped() public {
		king.mint(address(this), 23);
		vm.expectRevert(abi.encodeWithSelector(NoItemEquipped.selector, 23, 0));
		king.unequipItem(23, 0);
	}

	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure override returns (bytes4) {
		return this.onERC721Received.selector;
	}
}
