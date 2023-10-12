// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StakedNFT} from "../src/StakedNFT.sol";
import {ERC20Reward} from "../src/ERC20Reward.sol";
import {NFTRewardStaking} from "../src/NFTRewardStaking.sol";

contract DeployStakedNFT is Script {
    // struct of deployed contracts
    struct ContractList {
        StakedNFT stakedNFT;
        ERC20Reward rewardToken;
        NFTRewardStaking nftRewardStaking;
    }

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;
    address public deployerAddress;
    bytes32 public merkleProof;
    ContractList public contractList;
    

    function run() external returns (ContractList memory contractlist) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        deployerAddress = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);
        StakedNFT stakedNFT = new StakedNFT(deployerAddress, merkleProof);
        ERC20Reward erc20Reward = new ERC20Reward();
        NFTRewardStaking nftRewardStaking = new NFTRewardStaking(address(stakedNFT), address(erc20Reward), deployerAddress);
        vm.stopBroadcast();

        contractList = ContractList(stakedNFT, erc20Reward, nftRewardStaking);
        return contractList;
    }
}