---
name: Zama Confidential Perpetual Futures
description: The elite guide to building private perpetual futures exchanges on FHEVM. Learn to manage encrypted positions, hidden leverage, and private liquidations.
category: Finance
difficulty: advanced
tags: [fhevm, solidity, perpetuals, futures, leverage, privacy]
estimated_time: 8 hours
---

# Zama Confidential Perpetual Futures

Perpetual futures are the most traded instruments in crypto. However, standard on-chain perps reveal user positions, liquidation prices, and leverage, allowing for predatory front-running. This guide teaches you how to build a fully confidential perp exchange.

## 1. Overview
In a Confidential Perpetual Exchange:
- **Positions**: The size of a user's long or short is encrypted.
- **Leverage**: The specific leverage used is hidden from the public.
- **Liquidation**: Liquidations are triggered based on encrypted margin checks.

## 2. Prerequisites
- Deep understanding of perpetual futures (Funding rates, Margin, Liquidations).
- Mastery of the `zama-confidential-erc20-token` and `zama-solidity-encrypted-types` skills.

## 3. Step-by-Step Implementation

### Step 1: Encrypted Position State
Instead of public mappings, we store position data as `euint`.

```solidity
struct Position {
    euint32 size;      // Encrypted position size
    euint32 collateral; // Encrypted collateral
    ebool isLong;      // Encrypted direction
    euint32 entryPrice; // Price at entry (can be public or encrypted)
}
```

### Step 2: Opening a Position
Users submit encrypted size and collateral. The contract verifies margin requirements branchlessly.

```solidity
function openPosition(externalEuint32 size, externalEuint32 collateral, bytes calldata proof) public {
    euint32 s = FHE.fromExternal(size, proofS);
    euint32 c = FHE.fromExternal(collateral, proofC);
    
    // Leverage Check: s <= c * MAX_LEVERAGE
    ebool validLeverage = FHE.le(s, FHE.mul(c, FHE.asEuint32(MAX_LEVERAGE)));
    
    // Only update if valid (branchless)
    positions[msg.sender].size = FHE.select(validLeverage, s, positions[msg.sender].size);
    // ...
}
```

### Step 3: Funding and PnL
PnL is calculated using encrypted arithmetic based on the current public price.

```solidity
function calculatePnL(address user, uint32 currentPrice) public view returns (euint32) {
    Position storage pos = positions[user];
    // PnL = size * (currentPrice - entryPrice) / entryPrice
    // All operations happen homomorphically
}
```

### Step 4: Private Liquidations
Liquidations happen when `Collateral + PnL < MaintenanceMargin`. This check is performed using `FHE.lt` and the result is decrypted to trigger the liquidation.

```solidity
function checkLiquidation(address user) public {
    ebool isUnderwater = ...;
    FHE.requestDecryption([isUnderwater], this.liquidateCallback.selector);
}
```

## 4. Security Considerations
- **Oracle Latency**: Ensure your price feed is fresh to prevent stale-price attacks on encrypted positions.
- **Information Leakage**: The total Open Interest (OI) of the platform might still be public. Consider anonymizing the aggregate data.
- **Partial Liquidations**: Implementing partial liquidations requires more complex FHE logic to reduce size by a specific encrypted factor.

## 5. Gas Optimization Tips
- **Pre-calculate Constants**: Convert frequently used values (like `MAX_LEVERAGE`) into `euint` handles once in the constructor.
- **Minimize Decryptions**: Only check liquidations for positions that are likely close to the margin (use a public "safety buffer" to filter).

## 6. Common Pitfalls & Solutions
- **Funding Rate Complexity**: Calculating continuous funding rates is math-heavy. Simplify to discrete funding periods to save gas.
- **Reentrancy**: Decryption callbacks are external calls. Use the `zama-fhevm-reentrancy-protection` pattern.

## 7. Full Implementation Reference
The `references/` folder includes a simplified perpetual engine with:
- `ConfidentialPerps.sol`: The core exchange logic.
- `MarginVault.sol`: Encrypted collateral management.
- `PerpTest.ts`: Simulation of trade execution and liquidation.

## 8. Self-Contained References
Check the `references/` folder for:
- `FHE.sol`
- `FHEVMConfig.sol`
- `ConfidentialPerps.sol`
- `PerpTest.ts`
- `README.md`
