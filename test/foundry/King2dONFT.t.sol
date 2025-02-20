// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TestHelper } from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import { MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { King2dONFT, NotApprovedOrOwner } from "../../contracts/ERC721/King2dONFT.sol";
import { King2dONFTMock } from "../../contracts/Mock/King2dONFT.sol";

import "forge-std/console.sol";

contract Test_BridgeGateway is TestHelper {
	using OptionsBuilder for bytes;
	using Strings for uint256;

	King2dONFTMock public king2dONFTA;
	King2dONFT public king2dONFTB;

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

		king2dONFTA = new King2dONFTMock(endpoints[aEid], address(0));
		king2dONFTB = new King2dONFT(endpoints[bEid], address(0));

		address[] memory oapps = new address[](2);
		oapps[1] = address(king2dONFTA);
		oapps[0] = address(king2dONFTB);
		super.wireOApps(oapps);
	}

	function test_constructor() public {
		assertEq(king2dONFTA.owner(), address(this));
		assertEq(king2dONFTB.owner(), address(this));
	}

	function test_fuzzBridgeAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge king2dONFTA (userA) --> King2dONFTB (userA)

		// mint token to userA
		king2dONFTA.mint(userA, _tokenId);
		assertEq(king2dONFTA.ownerOf(_tokenId), userA);

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0);
		MessagingFee memory fee = king2dONFTA.quote(bEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		king2dONFTA.bridge{ value: fee.nativeFee }(bEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(king2dONFTB)));

		assertEq(king2dONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(king2dONFTB.ownerOf(_tokenId), userA);

		/////////// bridge bEid - aEid
		// King2dONFTB (userA) --> king2dONFTA (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0);
		fee = king2dONFTB.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userA);
		king2dONFTB.bridge{ value: fee.nativeFee }(aEid, _tokenId, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(king2dONFTA)));

		assertEq(king2dONFTA.ownerOf(_tokenId), userA);
		assertEq(king2dONFTB.balanceOf(userA), 0); // nft is burned
	}

	function test_fuzzBridgeToAndBack(uint256 _tokenId) public {
		/////////// bridge aEid - bEid
		// bridge king2dONFTA (userA) --> King2dONFTB (userB)

		// mint token to userA
		king2dONFTA.mint(userA, _tokenId);
		assertEq(king2dONFTA.ownerOf(_tokenId), userA);

		// quote fees
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0);
		MessagingFee memory fee = king2dONFTA.quote(bEid, _tokenId, userB, options, false);

		// bridge
		vm.prank(userA);
		king2dONFTA.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(bEid, addressToBytes32(address(king2dONFTB)));

		assertEq(king2dONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(king2dONFTB.ownerOf(_tokenId), userB);

		/////////// bridge bEid - aEid
		// King2dONFTB (userB) --> king2dONFTA (userA)

		// quote fees
		options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0);
		fee = king2dONFTB.quote(aEid, _tokenId, userA, options, false);

		// bridge
		vm.prank(userB);
		king2dONFTB.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, options, false);

		// verify packets and execute on destination chain
		super.verifyPackets(aEid, addressToBytes32(address(king2dONFTA)));

		assertEq(king2dONFTA.ownerOf(_tokenId), userA);
		assertEq(king2dONFTB.balanceOf(userB), 0); // nft is burned
	}

	function test_fuzzBridgeAndBackWithEnforcedOptions(uint256 _tokenId) public {
		EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](1);
		// set enforced options for King2dONFTA
		enforcedOptions[0] = EnforcedOptionParam({
			eid: bEid,
			msgType: king2dONFTA.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0)
		});
		king2dONFTA.setEnforcedOptions(enforcedOptions);

		// set enforced options for King2dONFTB
		enforcedOptions[0] = EnforcedOptionParam({
			eid: aEid,
			msgType: king2dONFTB.BRIDGE(),
			options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(77500, 0)
		});
		king2dONFTB.setEnforcedOptions(enforcedOptions);

		king2dONFTA.mint(userA, _tokenId);
		assertEq(king2dONFTA.ownerOf(_tokenId), userA);

		MessagingFee memory fee = king2dONFTA.quote(bEid, _tokenId, userB, "", false);

		vm.prank(userA);
		king2dONFTA.bridgeTo{ value: fee.nativeFee }(bEid, _tokenId, userB, "", false);

		super.verifyPackets(bEid, addressToBytes32(address(king2dONFTB)));

		assertEq(king2dONFTA.balanceOf(userA), 0); // nft is burned
		assertEq(king2dONFTB.ownerOf(_tokenId), userB);

		fee = king2dONFTB.quote(aEid, _tokenId, userA, "", false);

		vm.prank(userB);
		king2dONFTB.bridgeTo{ value: fee.nativeFee }(aEid, _tokenId, userA, "", false);

		super.verifyPackets(aEid, addressToBytes32(address(king2dONFTA)));

		assertEq(king2dONFTA.ownerOf(_tokenId), userA);
		assertEq(king2dONFTB.balanceOf(userB), 0); // nft is burned
	}

	function test_fuzzOnlyOwnerOrApproved(uint256 _tokenId) public {
		king2dONFTA.mint(userA, _tokenId);
		assertEq(king2dONFTA.ownerOf(_tokenId), userA);

		vm.expectRevert(
			abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), _tokenId)
		);
		king2dONFTA.bridgeTo(bEid, _tokenId, userB, "", false);

		vm.expectRevert(
			abi.encodeWithSelector(NotApprovedOrOwner.selector, address(this), _tokenId)
		);
		king2dONFTA.bridge(bEid, _tokenId, "", false);
	}

	function test_fuzzExposeTokenURI(uint256 _tokenId) public {
		king2dONFTA.mint(userA, _tokenId);
		assertEq(king2dONFTA.ownerOf(_tokenId), userA);

		string memory expectedTokenURI = string(
			abi.encodePacked("https://nft.orivium.io/nft/king2d/", _tokenId.toString())
		);
		assertEq(king2dONFTA.tokenURI(_tokenId), expectedTokenURI);
	}
}
