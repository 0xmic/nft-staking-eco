// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract NFTRewardStaking is IERC721Receiver, Ownable2Step {
    using SafeERC20 for IERC20;

    IERC721 public stakedNFT;
    IERC20 public rewardToken;

    mapping(uint256 => address) public originalOwner;
    mapping(uint256 => uint256) public lastClaimed;

    uint256 public constant REWARDS_PER_PERIOD = 10 * 10**18; // 10 tokens every 24 hours
    uint256 public constant CLAIM_PERIOD = 1 days;

    event NFTStaked(address indexed owner, uint256 indexed tokenId);
    event RewardsClaimed(address indexed owner, uint256 indexed tokenId, uint256 amount);
    event NFTWithdrawn(address indexed owner, uint256 indexed tokenId);

    /**
     * @dev Constructor to initialize the contract with the NFT and reward token addresses
     * @param _stakedNFT Address of the NFT contract
     * @param _rewardToken Address of the ERC20 reward token contract
     * @param initialOwner Address of the initial owner of this contract
     */
    constructor(
        address _stakedNFT,
        address _rewardToken,
        address initialOwner
    ) Ownable(initialOwner) {
        require(_stakedNFT != address(0), "StakedNFT address cannot be zero");
        require(_rewardToken != address(0), "RewardToken address cannot be zero");

        stakedNFT = IERC721(_stakedNFT);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @dev Handles the receipt of an NFT and initializes the reward claiming process
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        require(msg.sender == address(stakedNFT), "Only stakedNFT can call this function");

        originalOwner[tokenId] = from;
        lastClaimed[tokenId] = block.timestamp;

        emit NFTStaked(from, tokenId);
        return this.onERC721Received.selector;
    }

    /**
     * @dev Allows the NFT owner to claim rewards
     * @param tokenId ID of the token being staked
     */
    function claimRewards(uint256 tokenId) public {
        require(originalOwner[tokenId] == msg.sender, "Not the original owner");

        uint256 timeElapsed = block.timestamp - lastClaimed[tokenId];
        require(timeElapsed >= CLAIM_PERIOD, "Claim too soon");

        uint256 periodsPassed = timeElapsed / CLAIM_PERIOD;
        uint256 rewards = periodsPassed * REWARDS_PER_PERIOD;

        lastClaimed[tokenId] = block.timestamp;
        rewardToken.safeTransfer(msg.sender, rewards);

        emit RewardsClaimed(msg.sender, tokenId, rewards);
    }

    /**
     * @dev Allows the NFT owner to withdraw their staked NFT
     * @param tokenId ID of the token being staked
     */
    function withdrawNFT(uint256 tokenId) public {
        require(originalOwner[tokenId] == msg.sender, "Not the original owner");

        delete originalOwner[tokenId];
        stakedNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTWithdrawn(msg.sender, tokenId);
    }
}
