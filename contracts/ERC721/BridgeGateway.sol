//SPDX-License-Identifier: MIT
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

import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";

import { OApp, Origin, MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { OAppOptionsType3 } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OAppOptionsType3.sol";

error ERC721IsZeroAddress();

contract BridgeGateway is IERC721Receiver, Context, OApp, OAppOptionsType3 {
	IERC721 public immutable erc721;

	uint16 public constant BRIDGE = 1;

	constructor(address _erc721, address _lzEndpoint) OApp(_lzEndpoint, _msgSender()) {
		if (_erc721 == address(0)) {
			revert ERC721IsZeroAddress();
		}
		erc721 = IERC721(_erc721);
	}

	function bridge(
		uint32 _dstEid,
		uint _tokenId,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) external payable {
		_bridgeTo(_dstEid, _tokenId, erc721.ownerOf(_tokenId), _extraOptions, _payInLzToken);
	}

	function bridgeTo(
		uint32 _dstEid,
		uint _tokenId,
		address _receiver,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) external payable {
		_bridgeTo(_dstEid, _tokenId, _receiver, _extraOptions, _payInLzToken);
	}

	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure override returns (bytes4) {
		return this.onERC721Received.selector;
	}

	function quote(
		uint32 _dstEid,
		uint _tokenId,
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
		uint _tokenId,
		address _receiver,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) internal {
		erc721.safeTransferFrom(_msgSender(), address(this), _tokenId);

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
		erc721.safeTransferFrom(address(this), owner, tokenId);
	}
}
