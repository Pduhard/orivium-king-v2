// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { TestHelper } from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { SendParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { IOAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";

import { OriviumOFT } from "../../contracts/ERC20/OriviumOFT.sol";
import { OriviumOFTAdapter } from "../../contracts/ERC20/OriviumOFTAdapter.sol";
import { OriviumOFT } from "../../contracts/ERC20/OriviumOFT.sol";
import { ORIToken } from "../../contracts/Mock/ORIToken.sol";

import "forge-std/console.sol";

contract Test_OriviumOFT is TestHelper {
	using OptionsBuilder for bytes;

	uint32 aEid = 1;
	uint32 bEid = 2;

	ORIToken oriviumA;
	OriviumOFTAdapter oriviumOFTAdapterA;
	OriviumOFT oriviumOFTB;

	address public userA = address(0x1);
	address public userB = address(0x2);

	function setUp() public virtual override {
		vm.deal(userA, 1000 ether);
		vm.deal(userB, 1000 ether);

		super.setUp();
		super.setUpEndpoints(3, LibraryType.UltraLightNode);

		oriviumA = new ORIToken(1000 ether);
		oriviumA.transfer(userA, 1000 ether);
		oriviumOFTAdapterA = new OriviumOFTAdapter(address(oriviumA), endpoints[aEid]);
		oriviumOFTB = new OriviumOFT(endpoints[bEid]);

		address[] memory ofts = new address[](2);
		ofts[0] = address(oriviumOFTAdapterA);
		ofts[1] = address(oriviumOFTB);
		super.wireOApps(ofts);
	}

	function test_send() public {
		uint256 tokensToSend = 1 ether;
		uint256 initialBalance = IERC20(oriviumOFTAdapterA.token()).balanceOf(userA);
		bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
		SendParam memory sendParam = SendParam(
			bEid,
			addressToBytes32(userA),
			tokensToSend,
			tokensToSend,
			options,
			"",
			""
		);

		MessagingFee memory fee = oriviumOFTAdapterA.quoteSend(sendParam, false);

		assertEq(IERC20(oriviumOFTAdapterA.token()).balanceOf(userA), initialBalance);
		assertEq(oriviumOFTB.balanceOf(userA), 0);

		vm.prank(userA);
		oriviumA.approve(address(oriviumOFTAdapterA), tokensToSend);

		vm.prank(userA);
		oriviumOFTAdapterA.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
		verifyPackets(bEid, addressToBytes32(address(oriviumOFTB)));

		assertEq(
			IERC20(oriviumOFTAdapterA.token()).balanceOf(userA),
			initialBalance - tokensToSend
		);
		assertEq(oriviumOFTB.balanceOf(userA), tokensToSend);

		// back to A

		sendParam = SendParam(
			aEid,
			addressToBytes32(userA),
			tokensToSend,
			tokensToSend,
			options,
			"",
			""
		);

		fee = oriviumOFTB.quoteSend(sendParam, false);

		vm.prank(userA);
		oriviumOFTB.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
		verifyPackets(aEid, addressToBytes32(address(oriviumOFTAdapterA)));

		assertEq(IERC20(oriviumOFTAdapterA.token()).balanceOf(userA), initialBalance);
		assertEq(oriviumOFTB.balanceOf(userA), 0);
	}
}
