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

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Staking721 } from "@orivium/thirdweb-dev/contracts/extension/Staking721.sol";

import { OApp, Origin, MessagingFee } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { OAppOptionsType3 } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OAppOptionsType3.sol";

error NotApprovedOrOwner(address sender, uint256 tokenId);

contract King2dONFT is ERC721, Staking721, OApp, OAppOptionsType3, IERC721Receiver {
	address public immutable REWARD_TOKEN;

	uint256 public constant TOTAL_SUPPLY = 4444;

	uint16 public constant BRIDGE = 1;

	constructor(
		address _lzEndpoint,
		address _rewardToken
	) ERC721("King2D", "KING2D") Staking721(address(this)) OApp(_lzEndpoint, _msgSender()) {
		REWARD_TOKEN = _rewardToken;
		_setStakingCondition(5, 0.00001 ether);
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return "https://nft.orivium.io/nft/king2d/";
	}

	/*********************************************
	 *                  STAKING                  *
	 ********************************************/

	function _canSetStakeConditions() internal view override returns (bool) {
		return msg.sender == owner();
	}

	function _mintRewards(address _staker, uint256 _rewards) internal override {
		IERC20(REWARD_TOKEN).transferFrom(address(this), _staker, _rewards);
	}

	function getRewardTokenBalance() external view override returns (uint256) {
		return IERC20(REWARD_TOKEN).balanceOf(address(this));
	}

	/*********************************************
	 *             LAYER ZERO BRIDGE             *
	 ********************************************/

	function bridge(
		uint32 _dstEid,
		uint _tokenId,
		bytes calldata _extraOptions,
		bool _payInLzToken
	) external payable {
		_bridgeTo(_dstEid, _tokenId, _ownerOf(_tokenId), _extraOptions, _payInLzToken);
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
		_mint(owner, tokenId);
	}

	/*********************************************
	 *                  UTILS                    *
	 ********************************************/

	function walletOfOwner(address _owner) external view returns (uint256[] memory) {
		uint256 tokenCount = balanceOf(_owner);
		uint256 index = 0;
		uint256[] memory tokensId = new uint256[](tokenCount);

		if (tokenCount == 0) return new uint256[](0);

		for (uint256 i = 1; i <= TOTAL_SUPPLY; i += 1) {
			if (_ownerOf(i) != _owner) continue;
			tokensId[index] = i;
			index++;
			if (index == tokenCount) break;
		}

		return tokensId;
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
