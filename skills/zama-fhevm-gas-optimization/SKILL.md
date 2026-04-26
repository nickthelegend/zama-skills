---
name: Zama FHEVM Gas Optimization
description: The ultimate guide to reducing gas costs in FHEVM applications. Learn about bit-width optimization, branchless arithmetic, and batching strategies.
category: Foundation
difficulty: advanced
tags: [fhevm, gas, optimization, efficiency, solidity]
estimated_time: 3.5 hours
---

# Zama FHEVM Gas Optimization

In FHEVM, gas is not just about compute cycles; it's about the complexity of the homomorphic operations. A single `FHE.mul` on `euint64` is significantly more expensive than an `euint8` addition. This guide teaches you how to build cost-effective FHE apps.

## 1. Overview
FHEVM gas costs are determined by:
1.  **Type Size**: Larger bit-widths cost exponentially more.
2.  **Operation Complexity**: Multiplication and Division are far more expensive than Addition and XOR.
3.  **ACL Operations**: Each `FHE.allow` consumes standard EVM gas for storage and computation.

## 2. The Golden Rules of FHE Gas

### Rule 1: Right-Size Your Types
Always use the smallest possible bit-width.

```solidity
// ❌ OVERKILL: Costs ~4x more gas
euint32 public counter;

// ✅ OPTIMIZED: Sufficient for values < 256
euint8 public counter;
```

### Rule 2: Bitwise over Arithmetic
Multiplication is expensive. If you are multiplying by a power of two, use a bitwise shift.

```solidity
// ❌ EXPENSIVE
euint32 result = FHE.mul(val, FHE.asEuint32(4));

// ✅ OPTIMIZED
euint32 result = FHE.shl(val, 2);
```

### Rule 3: Use Literals Correctly
Avoid `FHE.fromExternal` for constants. Use `FHE.asEuintX()` to create encrypted constants from public literals.

## 3. Batching Permissions
If you are updating many encrypted variables, use a multicall or an array-based permissioning strategy.

```solidity
// ❌ INEFFICIENT
FHE.allowThis(val1);
FHE.allowThis(val2);
FHE.allowThis(val3);

// ✅ BATCHED (Conceptual)
// In future versions, Zama plans to support FHE.allowBatch()
```

## 4. Branchless Logic Optimization
Minimize the number of `FHE.select` calls. Every select is a multiplication under the hood.

```solidity
// ❌ INEFFICIENT
euint32 res = FHE.select(c1, x, FHE.select(c2, y, z));

// ✅ BETTER
// Try to mathematically combine conditions if possible.
```

## 5. Gateway and KMS Interaction
Decryption requests are the most expensive part of the lifecycle (asynchronously).

- **Strategy**: Only decrypt when absolutely necessary for the core application logic.
- **Strategy**: Combine multiple values into a single `FHE.requestDecryption` call.

## 6. Real-World Benchmarks (Sepolia)

| Operation | euint8 Gas | euint32 Gas |
| :--- | :--- | :--- |
| `FHE.add` | ~40,000 | ~120,000 |
| `FHE.mul` | ~150,000 | ~450,000 |
| `FHE.select` | ~80,000 | ~200,000 |

*Note: These are estimates. Always benchmark your specific contract version.*

## 7. Self-Contained References
Check the `references/` folder for:
- `GasBenchmarks.md`: A detailed table of operation costs.
- `OptimizedContract.sol`: A sample contract before and after gas optimization.
- `README.md`: How to use the Hardhat gas reporter with FHEVM.
