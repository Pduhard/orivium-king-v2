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

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import { IStorageConsumer } from "./IStorageConsumer.sol";
import { IStorage } from "./IStorage.sol";

error AdminRoleZeroAddress();

contract Storage is AccessControlEnumerable, IStorage {
	bytes32 public constant STORAGE_ADMIN_ROLE = keccak256("STORAGE_ADMIN_ROLE");

	/// @dev List of consumers
	IStorageConsumer[] public consumers;

	constructor(address _adminRole) {
		if (_adminRole == address(0)) {
			revert AdminRoleZeroAddress();
		}
		_setupRole(DEFAULT_ADMIN_ROLE, _adminRole);
		_grantRole(STORAGE_ADMIN_ROLE, _adminRole);
	}

	function addConsumer(IStorageConsumer consumer) external onlyRole(STORAGE_ADMIN_ROLE) {
		consumers.push(consumer);
	}

	function removeConsumer(IStorageConsumer consumer) external onlyRole(STORAGE_ADMIN_ROLE) {
		for (uint256 i = 0; i < consumers.length; i++) {
			if (consumers[i] == consumer) {
				consumers[i] = consumers[consumers.length - 1];
				consumers.pop();
				break;
			}
		}
	}

	modifier notifyUpdate() {
		_;
		for (uint256 i = 0; i < consumers.length; i++) {
			consumers[i].onStorageUpdate();
		}
	}
}
