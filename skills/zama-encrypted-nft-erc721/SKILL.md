---
name: Zama Encrypted NFT (ERC721)
description: Premium guide to building confidential NFTs on FHEVM. Learn to encrypt NFT metadata, traits, and ownership details so they are only visible to authorized holders.
category: blockchain
tags: [fhevm, solidity, nft, erc721, privacy]
---

# Zama Encrypted NFT (ERC721)

This skill teaches you how to create NFTs where the underlying data (traits, rarity, or hidden content) is encrypted and only accessible to the owner or authorized users.

## 1. The Concept of Confidential Metadata

Standard NFTs have public metadata (via `tokenURI`). In a Confidential NFT, the metadata URI can point to encrypted data, or the contract itself can store encrypted traits using FHE types.

## 2. Core Implementation (`ConfidentialNFT.sol`)

The contract inherits from `ERC721` and `ZamaEthereumConfig`.

### State Variables
```solidity
import { FHE, euint8, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ConfidentialNFT is ERC721, ZamaEthereumConfig {
    // Encrypted rarity score for each token (0-255)
    mapping(uint256 => euint8) private _rarityScores;
    
    constructor() ERC721("ConfidentialNFT", "CNFT") {}
}
```

### Minting with Encrypted Traits
The minter (or an oracle) can set an encrypted rarity score.

```solidity
function mint(address to, uint256 tokenId, externalEuint8 encryptedRarity, bytes calldata proof) public onlyOwner {
    _safeMint(to, tokenId);
    euint8 rarity = FHE.fromExternal(encryptedRarity, proof);
    _rarityScores[tokenId] = rarity;
    
    // Allow the owner of the token to see the rarity
    FHE.allow(rarity, to);
    FHE.allowThis(rarity);
}
```

## 3. Viewing Encrypted Traits

Only the owner of the NFT can decrypt the rarity score.

### Frontend Integration
```typescript
const handle = await contract.getRarity(tokenId);
const clearRarity = await fhevm.userDecryptEuint(
    FhevmType.euint8,
    handle,
    contractAddress,
    userSigner
);
console.log(`Your NFT Rarity is: ${clearRarity}`);
```

## 4. Use Cases
- **Gaming**: Hidden stats for characters or items.
- **Digital Art**: "Blind box" reveals where the content is decrypted only after purchase.
- **Identity**: NFTs representing credentials with encrypted personal details.

## 5. Security Note
When an NFT is transferred, you must update the ACL permissions so the new owner can see the encrypted data and the old owner cannot (if desired).

```solidity
function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
    euint8 rarity = _rarityScores[tokenId];
    FHE.allow(rarity, to);
    // Note: FHEVM doesn't currently support 'disallow' easily;
    // permissions are usually tied to the handle + address at the Gateway level.
}
```

## 6. Self-Contained References
Check the `references/` folder for:
- `ConfidentialNFT.sol`: Complete contract source code.
- `NFTTest.ts`: Testing suite for confidential traits.
