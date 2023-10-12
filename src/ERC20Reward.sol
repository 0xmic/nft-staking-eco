/**
 * TODO: Add versioned imports
 * TODO: Add script/tests 
 */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";


contract ERC20Reward is ERC20 {
    constructor() ERC20("RewardToken", "RT") {
    }
}