# NFT Staking Ecosystem

Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract  

[X] Create an ERC721 NFT with a **supply of 20**.  

[X] Include **ERC 2918 royalty** in your contract to have a **reward rate of 2.5%** for any NFT in the collection. Use the openzeppelin implementation.  

[X] Addresses in a merkle tree **can mint NFTs at a discount**. Use the **bitmap methodology** described above. Use openzeppelin’s bitmap, don’t implement it yourself.  

[X] Create an **ERC20 contract that will be used to reward staking**.  

[X] Create and a **third smart contract** that can **mint new ERC20 tokens and receive ERC721 tokens**. A classic feature of NFTs is being able to receive them to stake tokens. **Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours**. Don’t forget about decimal places! The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it. IMPORTANT: your staking mechanism must follow the sequence in the video I recorded above (stake NFTs with safetransfer).  

[X] Make the **funds from the NFT sale** in the contract **withdrawable by the owner**. Use Ownable2Step.  

[ ] Important: Use a combination of unit tests and the gas profiler in foundry or hardhat to measure the gas cost of the various operations.  

## Discounted Minting

Requirements:  
* **Whitelisted Ethereum Address**: You must have your Ethereum address that was included in the whitelist - this is defined by the merkleRoot set on contract creation.  
* **Merkle Proof Data**: The project/contract deployer will provide users with Merkle proofs for their associated whitelisted address. This is a series of hash values that prove your address is included in the Merkle Tree.  