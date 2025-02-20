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

import { OApp, Origin, MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { OAppOptionsType3 } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OAppOptionsType3.sol";

import { KingV2, NotApprovedOrOwner } from "./KingV2.sol";
import { IItem } from "./IItem.sol";

import "forge-std/console.sol";

contract KingONFT is KingV2, OApp, OAppOptionsType3 {
	uint16 public constant BRIDGE = 1;

	/// @dev mapping between tokenId and the itemIds to mint on bridge receive
	mapping(uint256 => mapping(uint256 => uint256)) public itemIdsToMintOnBridge;
	mapping(uint256 => uint256) public itemIdsToMintOnBridgeCount;

	constructor(
		address _lzEndpoint,
		address _itemAddress,
		uint256[][] memory _itemIdsToMintOnBridge
	) KingV2(_itemAddress) OApp(_lzEndpoint, _msgSender()) {
		for (uint256 i = 0; i < _itemIdsToMintOnBridge.length; i++) {
			uint256 tokenId = i + 1;
			itemIdsToMintOnBridgeCount[tokenId] = _itemIdsToMintOnBridge[i].length;
			for (uint256 j = 0; j < itemIdsToMintOnBridgeCount[tokenId]; j++) {
				itemIdsToMintOnBridge[tokenId][j] = _itemIdsToMintOnBridge[i][j];
			}
		}
	}

	function bridge(
		uint32 _dstEid,
		uint256 _tokenId,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) external payable {
		_bridgeTo(_dstEid, _tokenId, ownerOf(_tokenId), _extraOptions, _payInLzToken);
	}

	function bridgeTo(
		uint32 _dstEid,
		uint256 _tokenId,
		address _receiver,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) external payable {
		_bridgeTo(_dstEid, _tokenId, _receiver, _extraOptions, _payInLzToken);
	}

	function quote(
		uint32 _dstEid,
		uint256 _tokenId,
		address _receiver,
		bytes calldata _extraOptions, // Extra message execution options
		bool _payInLzToken // boolean for which token to return fee in
	) external view returns (MessagingFee memory fee) {
		bytes memory payload = abi.encode(_receiver, _tokenId);
		bytes memory options = combineOptions(_dstEid, BRIDGE, _extraOptions);
		return _quote(_dstEid, payload, options, _payInLzToken);
	}

	function _bridgeTo(
		uint32 _dstEid,
		uint256 _tokenId,
		address _receiver,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) internal {
		if (!_isApprovedOrOwner(_msgSender(), _tokenId))
			revert NotApprovedOrOwner(_msgSender(), _tokenId);
		_burn(_tokenId);

		bytes memory payload = abi.encode(_receiver, _tokenId);
		bytes memory options = combineOptions(_dstEid, BRIDGE, _extraOptions);

		MessagingFee memory fee = _quote(_dstEid, payload, options, _payInLzToken);

		_lzSend(_dstEid, payload, options, fee, payable(_msgSender()));
	}

	function _lzReceive(
		Origin calldata, // struct containing info about the message sender
		bytes32, // global packet identifier
		bytes calldata _payload, // encoded message payload being received
		address, // the Executor address.
		bytes calldata // arbitrary data appended by the Executor
	) internal override {
		(address owner, uint256 tokenId) = abi.decode(_payload, (address, uint256));
		_mintKingAndItems(owner, tokenId);
	}

	function _mintKingAndItems(address _to, uint256 _tokenId) internal {
		_mint(_to, _tokenId);
		uint256 count = itemIdsToMintOnBridgeCount[_tokenId];
		if (count > 0) {
			itemIdsToMintOnBridgeCount[_tokenId] = 0;
			for (uint256 i = 0; i < count; i++) {
				uint256 itemTokenId = itemIdsToMintOnBridge[_tokenId][i];
				IItem(ITEM).mint(address(this), itemTokenId);
				uint256 itemCategoryId = IItem(ITEM).getItemCategoryId(itemTokenId);
				equippedItems[_tokenId][itemCategoryId] = itemTokenId;
			}
		}
	}
}
