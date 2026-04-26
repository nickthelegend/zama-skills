---
name: Zama FHEVM Gas Optimization
description: Premium guide to optimizing gas usage in FHEVM contracts. Learn about the costs of different euint types, batching FHE.allow calls, and minimizing Gateway operations.
category: blockchain
tags: [fhevm, gas, optimization, solidity, efficiency]
---

# Zama FHEVM Gas Optimization

Gas management in FHEVM is significantly different from standard Solidity. FHE operations have high fixed costs, making optimization crucial for production apps.

## 1. Type Selection

Every bit matters. Using the smallest possible type can save up to 60% in gas costs for certain operations.

| Type | Relative Cost | Best Use Case |
| --- | --- | --- |
| `euint8` | Low | Flags, small counters, Wordle chars |
| `euint32` | Medium | Currency amounts, standard counters |
| `euint64` | High | High-value balances, large math |

## 2. Batching Permissions

Every `FHE.allow` call consumes gas. Batch your permissions whenever possible.

```solidity
// ❌ LESS EFFICIENT
FHE.allow(val1, user);
FHE.allow(val2, user);

// ✅ MORE EFFICIENT
// Consider if your contract can use one handle to represent multiple values or use arrays.
```

## 3. Off-chain vs On-chain

Only encrypt what **needs** to be secret.
- **Example**: If you are building a private auction, the `endTime` should be a public `uint256`, while the `bidAmount` is an `euint64`.

## 4. Arithmetic Optimization

- **Shifts vs Div/Mul**: Use `FHE.shl` and `FHE.shr` for power-of-two math. It's much cheaper than `FHE.div` or `FHE.mul`.
- **Pre-computed Tables**: If you have complex non-linear logic, pre-compute results and use an encrypted index to look them up.

## 5. Gateway and KMS Loops
Minimize the number of decryption requests. One `FHE.requestDecryption` with an array of 5 handles is cheaper than 5 separate requests.

## 6. Self-Contained References
Check the `references/` folder for:
- `GasBenchmarks.md`: Comparative table of operation costs.
- `OptimizedContract.sol`: Example of a gas-efficient FHE implementation.
