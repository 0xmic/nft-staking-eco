// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ERC20Reward is ERC20, Ownable2Step {
    constructor(address initialOwner) 
        ERC20("RewardToken", "RT") 
        Ownable(initialOwner) 
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}