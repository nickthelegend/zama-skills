---
name: Zama Confidential Order Book DEX
description: Premium guide to building a private Order Book DEX on FHEVM. Learn to match encrypted buy and sell orders using FHE.select and protect traders from front-running.
category: blockchain
tags: [fhevm, solidity, dex, order-book, finance]
---

# Zama Confidential Order Book DEX

Most DEXs use AMMs because order books are difficult to build on-chain without revealing every trader's intention. Zama enables a fully private order book where matches happen in the shadows.

## 1. Submitting Encrypted Orders

Traders submit their desired price and volume as encrypted values.

```solidity
struct Order {
    address trader;
    euint32 price;
    euint32 volume;
    bool isBuy;
}
```

## 2. The Matching Engine

The contract iterates through open orders and uses `FHE.select` to determine if a match exists without revealing the prices.

```solidity
function matchOrders(uint256 buyId, uint256 sellId) public {
    Order storage buy = buyOrders[buyId];
    Order storage sell = sellOrders[sellId];
    
    // Check if buy price >= sell price
    ebool isMatch = FHE.ge(buy.price, sell.price);
    
    // Determine the trade price (e.g., the midpoint)
    euint32 tradePrice = FHE.select(isMatch, FHE.div(FHE.add(buy.price, sell.price), 2), FHE.asEuint32(0));
    
    // Execute trade if isMatch is true
    // ...
}
```

## 3. MEV Protection
By keeping the order book encrypted, searchers cannot see the orders in the mempool to front-run them. This eliminates Sandwich attacks and other toxic MEV.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialDEX.sol`: A matching engine implementation in FHE.
- `DEXTest.ts`: Tests for verifying matches without price leaks.
