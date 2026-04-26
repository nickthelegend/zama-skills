---
name: Zama Private NFT Marketplace
description: Premium guide to building a confidential NFT marketplace on FHEVM. Learn to implement hidden reserve prices, encrypted bids, and private royalty distributions.
category: Finance
difficulty: advanced
tags: [fhevm, solidity, nft, erc721, marketplace, privacy]
estimated_time: 5 hours
---

# Zama Private NFT Marketplace

Standard NFT marketplaces (like OpenSea) are entirely transparent. This allows for sniping, bid manipulation, and front-running. A Private NFT Marketplace on FHEVM allows sellers to set hidden reserve prices and buyers to submit encrypted bids.

## 1. Overview
In a Private Marketplace:
- **Listings**: The reserve price (the minimum price the seller will accept) is encrypted.
- **Bidding**: Bids are submitted as `euint` values.
- **Matching**: The marketplace matches the highest bid to the reserve price without revealing either value until the sale is finalized.

## 2. Prerequisites
- Familiarity with the `zama-encrypted-nft-erc721` skill.
- Understanding of the `zama-confidential-erc20-token` (for payments).

## 3. Step-by-Step Implementation

### Step 1: Encrypted Listing
The seller lists an NFT with an encrypted minimum price.

```solidity
struct Listing {
    address seller;
    uint256 tokenId;
    euint32 reservePrice; // Hidden from the public
    bool active;
}
```

### Step 2: Encrypted Bidding
Buyers submit bids using encrypted ERC20 handles.

```solidity
function placeBid(uint256 listingId, externalEuint32 amount, bytes calldata proof) public {
    euint32 bidAmount = FHE.fromExternal(amount, proof);
    
    // Lock the bidder's tokens in escrow (encrypted)
    // ...
}
```

### Step 3: The Matching Engine
The contract checks if the bid is greater than or equal to the reserve price.

```solidity
function acceptBid(uint256 listingId, address bidder) public onlyOwner {
    Listing storage l = listings[listingId];
    euint32 bid = bids[listingId][bidder];
    
    ebool isAccepted = FHE.ge(bid, l.reservePrice);
    
    // Transfer NFT if accepted (branchless)
    // Note: Actual NFT transfer often requires a decryption or a specific ACL logic
}
```

## 4. Private Royalties
Royalties can be calculated on the encrypted sale price and distributed to the creator's encrypted balance, ensuring that high-value sales don't leak the artist's total income.

## 5. Security Considerations
- **Metadata Privacy**: While the price is hidden, the fact that an NFT was traded is still public. Use the `zama-encrypted-nft-erc721` skill to also hide the token's metadata.
- **Auction Sniping**: Use a commit-reveal or a timelock pattern (see `zama-confidential-timelock-controller`) to prevent last-second sniping based on gas patterns.

## 6. Gas Optimization Tips
- **Index Bids**: Use an encrypted sorting algorithm or simply track the current highest bidder using `FHE.select` to avoid expensive loops over many bids.

## 7. Common Pitfalls & Solutions
- **Infinite Bids**: Since bids are secret, a malicious user could try to submit a bid they can't afford. The marketplace must verify the encrypted balance of the bidder during the bid placement.

## 8. Self-Contained References
Check the `references/` folder for:
- `PrivateMarketplace.sol`: Full matching and settlement logic.
- `AuctionNFT.sol`: A compatible confidential ERC721.
- `MarketTest.ts`: Testing suite for hidden reserve auctions.
