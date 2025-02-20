// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import { TestHelper } from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import { MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { KingONFT, NotApprovedOrOwner } from "../../contracts/ERC721/KingONFT.sol";
import { KingONFTMock } from "../../contracts/Mock/KingONFT.sol";
import { ERC721Item } from "../../contracts/ERC721/ERC721Item.sol";

import { ItemHelper } from "./ItemHelper.sol";

// import "forge-std/console.sol";

contract TestBridgeGateway is TestHelper, ItemHelper, IERC721Receiver {
	using OptionsBuilder for bytes;
	using Strings for uint256;

	KingONFTMock public kingONFTA;
	KingONFT public kingONFTB;
	ERC721Item public itemA;
	ERC721Item public itemB;

	uint32 aEid = 1;
	uint32 bEid = 2;
	uint32 cEid = 3;

	address public userA = address(0x1);
	address public userB = address(0x2);

	function setUp() public override {
		vm.deal(userA, 1000 ether);
		vm.deal(userB, 1000 ether);

		super.setUp();
		super.setUpEndpoints(3, LibraryType.UltraLightNode);

		uint256[][] memory itemIdsToMintOnFirstBridge = new uint256[][](3);
		itemIdsToMintOnFirstBridge[0] = new uint256[](3);
		itemIdsToMintOnFirstBridge[0][0] = 1;
		itemIdsToMintOnFirstBridge[0][1] = 2;
		itemIdsToMintOnFirstBridge[0][2] = 3;

		initializeStorages();
		itemA = new ERC721Item(address(metadataStorage));
		itemB = new ERC721Item(address(metadataStorage));
		kingONFTA = new KingONFTMock(endpoints[aEid], address(itemA), itemIdsToMintOnFirstBridge);
		kingONFTB = new KingONFT(endpoints[bEid], address(itemB), itemIdsToMintOnFirstBridge);

		address[] memory oapps = new address[](2);
		oapps[1] = address(kingONFTA);
		oapps[0] = address(kingONFTB);
		super.wireOApps(oapps);
	}

	// non sense test
	// function testBig(uint256 _tokenId) public {
	// 	updateSorageWithBigDataset();
	// 	uint256 itemCount = 12000;
	// 	uint256[][] memory itemIdsToMintOnFirstBridge = new uint256[][](itemCount);
	// 	for (uint256 i = 0; i < itemCount; i++) {
	// 		itemIdsToMintOnFirstBridge[i] = new uint256[](3);
	// 		itemIdsToMintOnFirstBridge[i][0] = i + 1;
	// 		itemIdsToMintOnFirstBridge[i][1] = i + 2;
	// 		itemIdsToMintOnFirstBridge[i][2] = i + 3;
	// 	}

	// 	kingONFTA = new KingONFTMock(endpoints[aEid], address(itemA), itemIdsToMintOnFirstBridge);
	// 	kingONFTB = new KingONFT(endpoints[bEid], address(itemB), itemIdsToMintOnFirstBridge);

	// 	address[] memory oapps = new address[](2);
	// 	oapps[1] = address(kingONFTA);
	// 	oapps[0] = address(kingONFTB);
	// 	super.wireOApps(oapps);

	// 	for (uint256 tokenId = 0; tokenId < itemCount / 3; tokenId++) {
	// 		kingONFTA.mint(userA, tokenId);
	// 		assertEq(kingONFTA.ownerOf(tokenId), userA);

	// 		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(
	// 			1200000,
	// 			0
	// 		);
	// 		MessagingFee memory fee = kingONFTA.quote(bEid, tokenId, userB, options, false);

	// 		vm.prank(userA);
	// 		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, tokenId, userB, options, false);

	// 		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

	// 		vm.prank(userB);
	// 		kingONFTB.unequipItem(tokenId, 0);

	// 		assertEq(kingONFTB.ownerOf(tokenId), userB);
	// 		assertEq(kingONFTB.equippedItems(tokenId, 0), tokenId * 3 + 1);
	// 		assertEq(kingONFTB.equippedItems(tokenId, 1), tokenId * 3 + 2);
	// 		assertEq(kingONFTB.equippedItems(tokenId, 2), tokenId * 3 + 3);
	// 	}
	// }

	function testConstructor() public {
		assertEq(kingONFTA.owner(), address(this));
		assertEq(kingONFTB.owner(), address(this));
	}

	function testBridgeMint() public {
		uint256 tokenId = 1;
		kingONFTA.mint(userA, tokenId);
		assertEq(kingONFTA.ownerOf(tokenId), userA);

		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = kingONFTA.quote(bEid, tokenId, userB, options, false);

		vm.prank(userA);
		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, tokenId, userB, options, false);

		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		vm.prank(userB);
		kingONFTB.unequipItem(tokenId, 0);

		assertEq(kingONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(kingONFTB.ownerOf(tokenId), userB);

		assertEq(itemB.ownerOf(1), userB);
		assertEq(kingONFTB.equippedItems(tokenId, 0), 0);
		assertEq(kingONFTB.equippedItems(tokenId, 1), 2);
		assertEq(kingONFTB.equippedItems(tokenId, 2), 3);
	}

	function testBridgeMintTwice() public {
		uint256 tokenId = 1;
		kingONFTA.mint(address(this), tokenId);

		// first bridge
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = kingONFTA.quote(bEid, tokenId, address(this), options, false);
		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, tokenId, address(this), options, false);
		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		// bridge back
		fee = kingONFTB.quote(aEid, tokenId, address(this), options, false);
		kingONFTB.bridgeTo{ value: fee.nativeFee }(aEid, tokenId, address(this), options, false);
		super.verifyPackets(aEid, addressToBytes32(address(kingONFTA)));

		// second bridge
		fee = kingONFTA.quote(bEid, tokenId, address(this), options, false);
		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, tokenId, address(this), options, false);
		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		kingONFTB.unequipItem(tokenId, 0);

		assertEq(kingONFTA.balanceOf(address(this)), 0);
		assertEq(kingONFTB.ownerOf(tokenId), address(this));

		assertEq(itemB.ownerOf(1), address(this));
		assertEq(kingONFTB.equippedItems(tokenId, 0), 0);
		assertEq(kingONFTB.equippedItems(tokenId, 1), 2);
		assertEq(kingONFTB.equippedItems(tokenId, 2), 3);
	}

	function testFuzzBridgeAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge kingONFTA (userA) --> KingONFTB (userA)

		// mint token to userA
		kingONFTA.mint(userA, _tokenId);
		assertEq(kingONFTA.ownerOf(_tokenId), userA);

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = kingONFTA.quote(bEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		kingONFTA.bridge{ value: fee.nativeFee }(bEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		assertEq(kingONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(kingONFTB.ownerOf(_tokenId), userA);

		/////////// bridge bEid - aEid
		// KingONFTB (userA) --> kingONFTA (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		fee = kingONFTB.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		kingONFTB.bridge{ value: fee.nativeFee }(aEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(kingONFTA)));

		assertEq(kingONFTA.ownerOf(_tokenId), userA);
		assertEq(kingONFTB.balanceOf(userA), 0); // nft is burned
	}

	function testFuzzBridgeToAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge kingONFTA (userA) --> KingONFTB (userB)

		// mint token to userA
		kingONFTA.mint(userA, _tokenId);
		assertEq(kingONFTA.ownerOf(_tokenId), userA);

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = kingONFTA.quote(bEid, _tokenId, userB, options, false);

		// bridge
		vm.prank(userA);
		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		assertEq(kingONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(kingONFTB.ownerOf(_tokenId), userB);

		/////////// bridge bEid - aEid
		// KingONFTB (userB) --> kingONFTA (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		fee = kingONFTB.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userB);
		kingONFTB.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(kingONFTA)));

		assertEq(kingONFTA.ownerOf(_tokenId), userA);
		assertEq(kingONFTB.balanceOf(userB), 0); // nft is burned
	}

	function testFuzzBridgeAndBackWithEnforcedOptions(uint256 _tokenId) public {
		EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](1);
		// set enforced options for kingONFTA
		enforcedOptions[0] = EnforcedOptionParam({
			eid: bEid,
			msgType: kingONFTA.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0)
		});
		kingONFTA.setEnforcedOptions(enforcedOptions);

		// set enforced options for kingONFTB
		enforcedOptions[0] = EnforcedOptionParam({
			eid: aEid,
			msgType: kingONFTB.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0)
		});
		kingONFTB.setEnforcedOptions(enforcedOptions);

		kingONFTA.mint(userA, _tokenId);
		assertEq(kingONFTA.ownerOf(_tokenId), userA);

		MessagingFee memory fee = kingONFTA.quote(bEid, _tokenId, userB, "", false);

		vm.prank(userA);
		kingONFTA.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, "", false);

		super.verifyPackets(bEid, addressToBytes32(address(kingONFTB)));

		assertEq(kingONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(kingONFTB.ownerOf(_tokenId), userB);

		fee = kingONFTB.quote(aEid, _tokenId, userA, "", false);

		vm.prank(userB);
		kingONFTB.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, "", false);

		super.verifyPackets(aEid, addressToBytes32(address(kingONFTA)));

		assertEq(kingONFTA.ownerOf(_tokenId), userA);
		assertEq(kingONFTB.balanceOf(userB), 0); // nft is burned
	}

	function testFuzzOnlyOwnerOrApproved(uint256 _tokenId) public {
		kingONFTA.mint(userA, _tokenId);
		assertEq(kingONFTA.ownerOf(_tokenId), userA);

		vm.expectRevert(
			abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), _tokenId)
		);
		kingONFTA.bridgeTo(bEid, _tokenId, userB, "", false);

		vm.expectRevert(
			abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), _tokenId)
		);
		kingONFTA.bridge(bEid, _tokenId, "", false);
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
