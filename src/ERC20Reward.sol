/**
 * TODO: Add versioned imports
 * TODO: Add script/tests 
 */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor() ERC20("RewardToken", "RT") {
    }
}