---
name: Zama Confidential OTC Trade
description: Premium guide to building private Over-The-Counter (OTC) trading desks on FHEVM. Learn to match large buy/sell orders without leaking price or volume to the market.
category: finance
tags: [fhevm, solidity, otc, trading, privacy]
---

# Zama Confidential OTC Trade

OTC trades are large transactions that happen outside of standard order books to avoid market impact. FHEVM allows these trades to be executed on-chain with full privacy.

## 1. Setting Up a Quote

A liquidity provider (LP) sets an encrypted price for a specific asset.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialOTC is ZamaEthereumConfig {
    struct Quote {
        euint32 price;
        euint32 maxVolume;
        bool active;
    }
}
```

## 2. Executing a Trade

A trader submits their desired volume as an encrypted value. The contract verifies that it doesn't exceed `maxVolume` and calculates the total cost, all in FHE.

```solidity
function buy(uint256 quoteId, externalEuint32 amount, bytes calldata proof) public {
    euint32 buyAmount = FHE.fromExternal(amount, proof);
    Quote storage q = quotes[quoteId];
    
    // Check if buyAmount <= q.maxVolume
    ebool isValid = FHE.le(buyAmount, q.maxVolume);
    
    // Total Cost = buyAmount * q.price
    euint32 cost = FHE.mul(buyAmount, q.price);
    
    // Perform transfer if isValid is true
    // ...
}
```

## 3. Advantages
- **Zero Slippage**: Since the volume is hidden, bots cannot front-run the trade to create slippage.
- **Privacy for Large Players**: Institutions can move large positions without signaling their intentions to the rest of the market.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialOTC.sol`: Complete matching and settlement logic.
- `OTCProof.ts`: Script for generating ZK proofs for trade inputs.
