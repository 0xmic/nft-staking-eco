/**
 * TODO: Add versioned imports
 * TODO: Add script/tests 
 */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ERC721Royalty} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title StakedNFT
 * @dev This contract allows for the minting of a specific ERC721 NFT up to a max supply.
 * Owners can withdraw the funds collected from the minting process.
 */
contract StakedNFT is ERC721Royalty, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 private s_tokenCounter;
    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant PRICE = 1 ether;
    uint256 public constant DISCOUNT_PRICE = 0.5 ether;
    uint96 public ROYALTY_FEE;
    address public ROYALTY_RECEIVER;

    BitMaps.BitMap private discountBitMap;
    bytes32 public merkleRoot;

    // Events
    event NFTMinted(address indexed recipient, uint256 indexed tokenId);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event DiscountClaimed(address indexed recipient, uint256 indexed tokenId, uint256 indexed index);

    /**
     * @dev Contract initializer. Initializes the ERC721 and Ownable2Step contracts.
     * @param initialOwner The initial owner of the contract.
     */
    constructor(address initialOwner, bytes32 _merkleRoot) 
        ERC721("StakedNFT", "STKNFT") 
        Ownable(initialOwner) 
    {
        ROYALTY_RECEIVER = initialOwner;
        ROYALTY_FEE = 250; // 2.5%
        merkleRoot = _merkleRoot; // Discounted addresses

        _setDefaultRoyalty(ROYALTY_RECEIVER, ROYALTY_FEE);
    }

    /**
     * @dev Allows eligible addresses to mint an NFT at a discount.
     * The address must be included in the Merkle root and not have claimed the discount before.
     * @param merkleProof The Merkle proof to verify the caller's eligibility for the discount.
     */
    function claimDiscount(bytes32[] calldata merkleProof) external payable {
        bytes32 node = keccak256(abi.encodePacked(msg.sender));

        // Verify if the sender is eligible for the discount
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid Merkle proof");
        uint256 index = uint256(node) % 256;
        require(!discountBitMap.get(index), "Discount already claimed");
        require(msg.value == DISCOUNT_PRICE, "Ether value sent is not correct");

        // Update the bitmap to indicate that the discount has been claimed
        discountBitMap.setTo(index, true);

        _mint(msg.sender, s_tokenCounter);
        emit DiscountClaimed(msg.sender, s_tokenCounter, index);
        s_tokenCounter++;
    }

    /**
     * @dev Mints an NFT at the normal price.
     * Emits an {NFTMinted} event.
     */
    function mint() external payable {
        require(s_tokenCounter < MAX_SUPPLY, "Max supply reached");
        require(msg.value == PRICE, "Ether value sent is not correct");

        _mint(msg.sender, s_tokenCounter);
        emit NFTMinted(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    /**
     * @dev Returns the current balance of the contract.
     * @return The balance in wei.
     */
    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /** 
     * @dev Updates royalty using ERC2981
     */
    function setRoyalty(address _royaltyReceiver, uint96 _royaltyFee) external onlyOwner {
        ROYALTY_RECEIVER = _royaltyReceiver;
        ROYALTY_FEE = _royaltyFee;
        _setDefaultRoyalty(ROYALTY_RECEIVER, ROYALTY_FEE);
    }

    /**
     * @dev Allows the owner to withdraw the contract's balance.
     * @notice Only callable by the contract owner.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "Failed to send Ether");

        emit FundsWithdrawn(owner(), balance);
    }
}
