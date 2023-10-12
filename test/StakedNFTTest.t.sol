// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {StdCheats, console2} from "forge-std/StdCheats.sol";
import {ERC20Reward} from "../src/ERC20Reward.sol";
import {NFTRewardStaking} from "../src/NFTRewardStaking.sol";
import {StakedNFT} from "../src/StakedNFT.sol";
import {DeployStakedNFT} from "../script/DeployStakedNFT.s.sol";

contract BondingCurveTokenTest is StdCheats, Test {
    ERC20Reward public erc20Reward;
    StakedNFT public stakedNFT;
    NFTRewardStaking public nftRewardStaking;
    DeployStakedNFT public deployer;

    address public deployerAddress;

    function setUp() public {
        deployer = new DeployStakedNFT();
        DeployStakedNFT.ContractList memory contracts = deployer.run();
        stakedNFT = contracts.stakedNFT;
        erc20Reward = contracts.rewardToken;
        nftRewardStaking = contracts.nftRewardStaking;
        deployerAddress = deployer.deployerAddress();
    }

    function test_TokenName() public {
        assertEq(erc20Reward.name(), "RewardToken");
    }

    function test_ERC721CreationAndProperties() public {
        // TODO: Implement the test
    }

    function test_ERC2918Royalty() public {
        // TODO: Implement the test
    }

    function test_MerkleTreeDiscount() public {
        // TODO: Implement the test
    }

    function test_ERC20Contract() public {
        // TODO: Implement the test
    }

    function test_StakingContract() public {
        // TODO: Implement the test
    }

    function test_OwnerWithdrawal() public {
        // TODO: Implement the test
    }
}
