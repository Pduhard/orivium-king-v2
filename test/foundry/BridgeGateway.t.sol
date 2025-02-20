// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TestHelper } from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import { MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

import { KingONFT } from "../../contracts/ERC721/KingONFT.sol";
import { KingMock } from "../../contracts/Mock/King.sol";
import { Storage } from "../../contracts/ERC721/Storage.sol";
import { BridgeGateway, ERC721IsZeroAddress } from "../../contracts/ERC721/BridgeGateway.sol";

// import "forge-std/console.sol";

contract TestBridgeGateway is TestHelper {
	using OptionsBuilder for bytes;

	KingONFT public kingONFT;
	KingMock public mockERC721;
	BridgeGateway public bridgeGateway;

	uint32 public aEid = 1;
	uint32 public bEid = 2;
	uint32 public cEid = 3;

	address public userA = address(0x1);
	address public userB = address(0x2);

	function setUp() public override {
		vm.deal(userA, 1000 ether);
		vm.deal(userB, 1000 ether);

		super.setUp();
		super.setUpEndpoints(3, LibraryType.UltraLightNode);

		mockERC721 = new KingMock();
		bridgeGateway = new BridgeGateway(address(mockERC721), endpoints[aEid]);

		uint256[][] memory itemIdsToMintOnFirstBridge = new uint256[][](0);
		Storage storageContract = new Storage(address(this));
		kingONFT = new KingONFT(
			endpoints[bEid],
			address(storageContract),
			itemIdsToMintOnFirstBridge
		);

		address[] memory oapps = new address[](2);
		oapps[1] = address(bridgeGateway);
		oapps[0] = address(kingONFT);
		super.wireOApps(oapps);
	}

	function testConstructor() public {
		assertEq(address(bridgeGateway.erc721()), address(mockERC721));
		assertEq(bridgeGateway.owner(), address(this));

		vm.expectRevert(abi.encodeWithSelector(ERC721IsZeroAddress.selector));
		bridgeGateway = new BridgeGateway(address(0), endpoints[aEid]);
	}

	function testFuzzBridgeAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge mockERC721 (userA) --> BridgeGateway --> KingONFT (userA)

		// mint token to userA
		mockERC721.mint(userA, _tokenId);
		assertEq(mockERC721.ownerOf(_tokenId), userA);

		// approve bridgeGateway to transfer userA token
		vm.prank(userA);
		mockERC721.approve(address(bridgeGateway), _tokenId);
		assertEq(mockERC721.getApproved(_tokenId), address(bridgeGateway));

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = bridgeGateway.quote(bEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		bridgeGateway.bridge{ value: fee.nativeFee }(bEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(kingONFT)));

		assertEq(mockERC721.ownerOf(_tokenId), address(bridgeGateway));
		assertEq(kingONFT.ownerOf(_tokenId), userA);

		/////////// bridge bEid - aEid
		// KingONFT (userA) --> BridgeGateway --> mockERC721 (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		fee = kingONFT.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		kingONFT.bridge{ value: fee.nativeFee }(aEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(bridgeGateway)));

		assertEq(mockERC721.ownerOf(_tokenId), userA);
		assertEq(kingONFT.balanceOf(userA), 0); // nft is burned
	}

	function testFuzzBridgeToAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge mockERC721 (userA) --> BridgeGateway --> KingONFT (userB)

		// mint token to userA
		mockERC721.mint(userA, _tokenId);
		assertEq(mockERC721.ownerOf(_tokenId), userA);

		// approve bridgeGateway to transfer userA token
		vm.prank(userA);
		mockERC721.approve(address(bridgeGateway), _tokenId);
		assertEq(mockERC721.getApproved(_tokenId), address(bridgeGateway));

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		MessagingFee memory fee = bridgeGateway.quote(bEid, _tokenId, userB, options, false);

		// bridge
		vm.prank(userA);
		bridgeGateway.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(kingONFT)));

		assertEq(mockERC721.ownerOf(_tokenId), address(bridgeGateway));
		assertEq(kingONFT.ownerOf(_tokenId), userB);

		/////////// bridge bEid - aEid
		// KingONFT (userB) --> BridgeGateway --> mockERC721 (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0);
		fee = kingONFT.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userB);
		kingONFT.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(bridgeGateway)));

		assertEq(mockERC721.ownerOf(_tokenId), userA);
		assertEq(kingONFT.balanceOf(userB), 0); // nft is burned
	}

	function testFuzzBridgeAndBackWithEnforcedOptions(uint256 _tokenId) public {
		EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](1);
		// set enforced options for bridgeGateway
		enforcedOptions[0] = EnforcedOptionParam({
			eid: bEid,
			msgType: bridgeGateway.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0)
		});
		bridgeGateway.setEnforcedOptions(enforcedOptions);

		// set enforced options for kingONFT
		enforcedOptions[0] = EnforcedOptionParam({
			eid: aEid,
			msgType: kingONFT.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(1200000, 0)
		});
		kingONFT.setEnforcedOptions(enforcedOptions);

		mockERC721.mint(userA, _tokenId);
		assertEq(mockERC721.ownerOf(_tokenId), userA);

		vm.prank(userA);
		mockERC721.approve(address(bridgeGateway), _tokenId);
		assertEq(mockERC721.getApproved(_tokenId), address(bridgeGateway));

		MessagingFee memory fee = bridgeGateway.quote(bEid, _tokenId, userB, "", false);

		vm.prank(userA);
		bridgeGateway.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, "", false);

		super.verifyPackets(bEid, addressToBytes32(address(kingONFT)));

		assertEq(mockERC721.ownerOf(_tokenId), address(bridgeGateway));
		assertEq(kingONFT.ownerOf(_tokenId), userB);

		fee = kingONFT.quote(aEid, _tokenId, userA, "", false);

		vm.prank(userB);
		kingONFT.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, "", false);

		super.verifyPackets(aEid, addressToBytes32(address(bridgeGateway)));

		assertEq(mockERC721.ownerOf(_tokenId), userA);
		assertEq(kingONFT.balanceOf(userB), 0); // nft is burned
	}
}
