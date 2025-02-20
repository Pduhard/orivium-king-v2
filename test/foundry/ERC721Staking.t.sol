// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import { ERC721Staking } from "../../contracts/ERC721/ERC721Staking.sol";
import { KingMock } from "../../contracts/Mock/King.sol";
import { ORIToken } from "../../contracts/Mock/ORIToken.sol";

// import "forge-std/console.sol";

contract TestERC721Staking is Test, IERC721Receiver {
	ERC721Staking public erc721Staking;
	KingMock public king;
	ORIToken public oriToken;

	function setUp() public {
		oriToken = new ORIToken(100000000 ether);
		king = new KingMock();
		erc721Staking = new ERC721Staking(address(king), address(oriToken), 1 minutes, 1 ether);
		oriToken.transfer(address(erc721Staking), 100000000 ether);
	}

	function testConstructor() public {
		assertEq(erc721Staking.owner(), address(this));
		assertEq(address(erc721Staking.REWARD_TOKEN()), address(oriToken));
	}

	function testStake() public {
		king.mint(address(this), 1);
		king.mint(address(this), 2);
		king.setApprovalForAll(address(erc721Staking), true);

		uint256[] memory tokenIds = new uint256[](2);
		tokenIds[0] = 1;
		tokenIds[1] = 2;
		uint256 timestamp = block.timestamp;

		erc721Staking.stake(tokenIds);

		vm.warp(timestamp + 10 minutes);

		(uint256[] memory tokenStaked, uint256 reward) = erc721Staking.getStakeInfo(address(this));
		assertEq(tokenStaked.length, 2);
		assertEq(tokenStaked[0], 1);
		assertEq(tokenStaked[1], 2);
		assertEq(reward, 20 ether);
	}

	function testWithdraw() public {
		king.mint(address(this), 1);
		king.mint(address(this), 2);
		king.setApprovalForAll(address(erc721Staking), true);

		uint256[] memory tokenIds = new uint256[](2);
		tokenIds[0] = 1;
		tokenIds[1] = 2;
		uint256 timestamp = block.timestamp;

		erc721Staking.stake(tokenIds);

		vm.warp(timestamp + 10 minutes);

		erc721Staking.withdraw(tokenIds);

		(uint256[] memory tokenStaked, uint256 reward) = erc721Staking.getStakeInfo(address(this));
		assertEq(tokenStaked.length, 0);
		assertEq(king.ownerOf(1), address(this));
		assertEq(king.ownerOf(2), address(this));
		assertEq(reward, 20 ether);
	}

	function testClaimRewards() public {
		king.mint(address(this), 1);
		king.mint(address(this), 2);
		king.setApprovalForAll(address(erc721Staking), true);

		uint256[] memory tokenIds = new uint256[](2);
		tokenIds[0] = 1;
		tokenIds[1] = 2;
		uint256 timestamp = block.timestamp;

		erc721Staking.stake(tokenIds);

		vm.warp(timestamp + 10 minutes);

		erc721Staking.claimRewards();

		(uint256[] memory tokenStaked, uint256 reward) = erc721Staking.getStakeInfo(address(this));
		assertEq(tokenStaked.length, 2);
		assertEq(tokenStaked[0], 1);
		assertEq(tokenStaked[1], 2);
		assertEq(reward, 0);
		assertEq(oriToken.balanceOf(address(this)), 20 ether);
	}

	function testSetRewardsPerUnitTime() public {
		erc721Staking.setRewardsPerUnitTime(2 ether);
		assertEq(erc721Staking.getRewardsPerUnitTime(), 2 ether);
	}

	function testSetRewardsPerUnitTimeNotOwner() public {
		vm.prank(address(0x1));
		vm.expectRevert();
		erc721Staking.setRewardsPerUnitTime(2 ether);
		assertEq(erc721Staking.getRewardsPerUnitTime(), 1 ether);
	}

	function setTimeUnit() public {
		erc721Staking.setTimeUnit(2 minutes);
		assertEq(erc721Staking.getTimeUnit(), 2 minutes);
	}

	function setTimeUnitNotOwner() public {
		vm.prank(address(0x1));
		vm.expectRevert();
		erc721Staking.setTimeUnit(2 minutes);
		assertEq(erc721Staking.getTimeUnit(), 1 minutes);
	}

	// ERC721Receiver implementation
	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure override returns (bytes4) {
		return this.onERC721Received.selector;
	}
}
