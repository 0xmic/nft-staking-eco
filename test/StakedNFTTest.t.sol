// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {StdCheats, console2} from "forge-std/StdCheats.sol";
import {ERC20Reward} from "../src/ERC20Reward.sol";
import {NFTRewardStaking} from "../src/NFTRewardStaking.sol";
import {StakedNFT} from "../src/StakedNFT.sol";
import {DeployStakedNFT} from "../script/DeployStakedNFT.s.sol";

contract StakedNFTTest is StdCheats, Test {
    ERC20Reward public erc20Reward;
    StakedNFT public stakedNFT;
    NFTRewardStaking public nftRewardStaking;
    DeployStakedNFT public deployer;

    address public deployerAddress;
    address public testUser;

    function setUp() public {
        deployer = new DeployStakedNFT();
        DeployStakedNFT.ContractList memory contracts = deployer.run();
        stakedNFT = contracts.stakedNFT;
        erc20Reward = contracts.rewardToken;
        nftRewardStaking = contracts.nftRewardStaking;

        deployerAddress = deployer.deployerAddress();
        testUser = address(0x123);
    }

    /////////////////////////////////////////////////////////
    // ERC20Reward.sol 

    function test_TokenName() public {
        assertEq(erc20Reward.name(), "RewardToken");
    }

    function test_NonOwnerCantMint() public {
        vm.startPrank(testUser);
        vm.expectRevert();
        erc20Reward.mint(testUser, 1 ether);
        vm.stopPrank();
    }

    /////////////////////////////////////////////////////////
    // StakedNFT.sol 

    function test_ERC721CreationAndProperties() public {
        assertEq(stakedNFT.name(), "StakedNFT");
        assertEq(stakedNFT.symbol(), "STKNFT");
        assertEq(stakedNFT.MAX_SUPPLY(), 20);
        assertEq(stakedNFT.PRICE(), 1 ether);
    }

    function test_mintNFT() public {
        hoax(testUser, 1 ether);
        stakedNFT.mint{value: 1 ether}();
        
        assertEq(stakedNFT.balanceOf(testUser), 1);
        assertEq(stakedNFT.viewBalance(), 1 ether);
    }

    function test_setRoyalty() public {
        vm.startPrank(deployerAddress);
        stakedNFT.setRoyalty(deployerAddress, 100); // lower fee from 2.5% to 1%
        vm.stopPrank();

        assertEq(stakedNFT.ROYALTY_RECEIVER(), deployerAddress);
        assertEq(stakedNFT.ROYALTY_FEE(), 100);
    }

    function test_setRoyaltyFail() public {
        vm.startPrank(testUser);
        vm.expectRevert();
        stakedNFT.setRoyalty(address(testUser), 100);
        vm.stopPrank();
    }

    function test_withdraw() public {
        hoax(testUser, 1 ether);
        stakedNFT.mint{value: 1 ether}();

        vm.prank(deployerAddress);
        stakedNFT.withdraw();

        assertEq(stakedNFT.viewBalance(), 0);
        assertEq(address(deployerAddress).balance, 1 ether);
    }

    function test_withdrawFail() public {
        vm.startPrank(testUser);
        vm.expectRevert();
        stakedNFT.withdraw();
        vm.stopPrank();
    }

    function test_ERC2918Royalty() public {
        (address receiver, uint256 royaltyAmount) = stakedNFT.royaltyInfo(0, 1 ether);
        
        assertEq(receiver, deployerAddress);
        assertEq(royaltyAmount, 1 ether * stakedNFT.ROYALTY_FEE() / 10000);
    }

    function test_MerkleTreeDiscount() public {
        // TODO: Implement the test
    }

    /////////////////////////////////////////////////////////
    // NFTRewardStaking.sol 

    function test_StakingContract() public {
        // Deployer mints reward tokens and sends to staking contract
        hoax(deployerAddress, 100 ether);
        erc20Reward.mint(address(nftRewardStaking), 100 ether);
        assertEq(erc20Reward.balanceOf(address(nftRewardStaking)), 100 ether);

        // User mints NFT
        hoax(deployerAddress, 1 ether);
        stakedNFT.mint{value: 1 ether}();
        assertEq(stakedNFT.balanceOf(deployerAddress), 1);
        assertEq(stakedNFT.ownerOf(0), deployerAddress);

        // User stakes NFT
        vm.startPrank(deployerAddress);
        stakedNFT.approve(address(nftRewardStaking), 0);
        stakedNFT.safeTransferFrom(deployerAddress, address(nftRewardStaking), 0);

        // User waits for 1 period
        skip(nftRewardStaking.CLAIM_PERIOD() + 3600);

        // User claims rewards
        nftRewardStaking.claimRewards(0);

        // Check that the user has received the rewards
        assertEq(erc20Reward.balanceOf(deployerAddress), nftRewardStaking.REWARDS_PER_PERIOD());

        // User withdraws NFT
        nftRewardStaking.withdrawNFT(0);
        assertEq(stakedNFT.balanceOf(deployerAddress), 1);
    }
}
