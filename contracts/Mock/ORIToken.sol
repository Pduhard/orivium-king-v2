// contracts/ORIToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ORIToken is ERC20, ERC20Burnable {
	constructor(uint256 _initialSupply) ERC20("Orivium", "ORI") {
		_mint(_msgSender(), _initialSupply);
	}
}
