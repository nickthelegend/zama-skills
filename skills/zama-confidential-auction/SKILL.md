---
name: Zama Confidential Sealed-Bid Auction
description: Premium guide to building a private sealed-bid auction using FHEVM. Learn to process encrypted bids, compare them securely, and reveal the winner without exposing bid values.
category: blockchain
tags: [fhevm, solidity, auction, privacy, security]
---

# Zama Confidential Sealed-Bid Auction

This skill teaches you how to implement a fair and private auction mechanism where bids remain encrypted until the auction concludes.

## 1. Why Confidential Auctions?

In traditional on-chain auctions, bids are public. This allows for "bid sniping" and manipulation. Using FHE, bids are submitted as encrypted values, and the smart contract calculates the winner without ever seeing the actual amounts.

## 2. Core Implementation (`BlindAuction.sol`)

The contract uses `euint64` for bid amounts and `eaddress` for the winner's address.

### State Variables
```solidity
import { FHE, euint64, eaddress, ebool } from "@fhevm/solidity/lib/FHE.sol";

contract BlindAuction is ZamaEthereumConfig {
    euint64 private highestBid;
    eaddress private winningAddress;
    mapping(address => euint64) private bids;
}
```

### The Bidding Logic
Users submit an `externalEuint64` and an `inputProof`.

```solidity
function bid(externalEuint64 encryptedAmount, bytes calldata proof) public {
    euint64 amount = FHE.fromExternal(encryptedAmount, proof);
    
    // Transfer tokens (handles 0 transfer if balance is insufficient)
    token.confidentialTransferFrom(msg.sender, address(this), amount);
    
    euint64 currentTotal = FHE.add(bids[msg.sender], amount);
    bids[msg.sender] = currentTotal;

    // Compare with current highest bid using FHE.select
    ebool isNewWinner = FHE.gt(currentTotal, highestBid);
    highestBid = FHE.select(isNewWinner, currentTotal, highestBid);
    winningAddress = FHE.select(isNewWinner, FHE.asEaddress(msg.sender), winningAddress);
    
    FHE.allowThis(highestBid);
    FHE.allowThis(winningAddress);
}
```

## 3. Resolving the Auction

Once the auction ends, the contract requests a public decryption of the `winningAddress` through the Zama Decryption Oracle.

```solidity
function decryptWinner() public {
    bytes32[] memory cts = new bytes32[](1);
    cts[0] = FHE.toBytes32(winningAddress);
    FHE.requestDecryption(cts, this.callback.selector);
}

function callback(uint256 requestId, bytes memory cleartexts, bytes memory proof) public {
    FHE.checkSignatures(requestId, cleartexts, proof);
    winnerAddress = abi.decode(cleartexts, (address));
}
```

## 4. Claiming and Refunds

The winner can claim the prize, and other bidders can withdraw their (encrypted) refunds.

```solidity
function claim() public {
    require(msg.sender == winnerAddress);
    token.confidentialTransfer(beneficiary, highestBid);
    nft.transferFrom(address(this), winnerAddress, tokenId);
}
```

## 5. Security & Performance
- **Avoid Reverts**: The contract doesn't revert if a bid is too low or if funds are missing; it simply doesn't update the winner. This prevents "probing" for info via gas/error side-channels.
- **Type Choice**: `euint64` is used instead of `euint256` to optimize gas performance while being sufficient for most currency values.

## 6. Self-Contained References
Check the `references/` folder for:
- `BlindAuction.sol`: Complete contract source code.
- `ConfidentialToken.sol`: Token contract used for payments.
- `AuctionTest.ts`: Testing suite for the auction logic.
