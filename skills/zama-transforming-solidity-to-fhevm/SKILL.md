---
name: Transforming Solidity to FHEVM
description: The essential guide for migrating existing Solidity contracts to the confidential FHEVM paradigm. Learn to identify sensitive data, refactor logic, and manage private states.
category: Foundation
difficulty: advanced
tags: [fhevm, migration, solidity, refactoring, architecture]
estimated_time: 4 hours
---

# Transforming Solidity to FHEVM

Migrating a standard "transparent" smart contract to Zama's FHEVM is not a simple search-and-replace of `uint256` to `euint32`. It requires a fundamental shift in how you reason about state and control flow.

## 1. Overview: The Transparency Gap
In standard Solidity, every variable is public to anyone running a full node. In FHEVM, we introduce the concept of "Confidential State".

## 2. Transformation Workflow

### Phase 1: Data Sensitivity Audit
Identify every state variable and determine if it should be public, private (Solidity keyword), or **Confidential** (FHE type).

| Variable | Current Type | Proposed FHE Type | Reason |
| :--- | :--- | :--- | :--- |
| `balance` | `uint256` | `euint32` | User wealth should be secret. |
| `owner` | `address` | `address` | Contract ownership is usually public. |
| `bidAmount` | `uint256` | `euint64` | Prevent front-running in auctions. |

### Phase 2: Refactoring Logic
The biggest change is removing `if` statements that depend on secret data.

#### Standard Solidity
```solidity
if (balances[msg.sender] >= amount) {
    balances[msg.sender] -= amount;
}
```

#### FHEVM Solidity
```solidity
ebool canSpend = FHE.le(amount, balances[msg.sender]);
balances[msg.sender] = FHE.sub(balances[msg.sender], FHE.select(canSpend, amount, FHE.asEuint32(0)));
```

### Phase 3: Handling View Functions
Standard `view` functions that return `uint256` won't work for encrypted data. You must implement the Zama Decryption flow or provide encrypted handles for the Relayer SDK.

## 3. Migration Checklist

1.  **[ ] Change Types**: Convert sensitive `uint` to `euint`.
2.  **[ ] Update Interfaces**: Functions receiving secrets should use `externalEuint` and `bytes calldata proof`.
3.  **[ ] Remove Reverts**: Remove any `require` or `revert` that depends on the value of a secret.
4.  **[ ] Add ACL**: Ensure `FHE.allowThis()` is called whenever a secret is updated or stored.

## 4. Common Pitfalls & Solutions

- **Pitfall**: Attempting to use `require(FHE.decrypt(val) > 0)`.
- **Solution**: This leaks data. Use a "silent failure" pattern where the operation completes but does nothing if the condition is not met.

- **Pitfall**: Using `euint64` for everything.
- **Solution**: This will blow up your gas costs. Analyze your value ranges and use the smallest possible bit-width.

## 5. Security Considerations
- **Metadata Leakage**: Even if the values are encrypted, the *timing* and *address* of transactions are still public. Consider using mixers or relayers for full anonymity.

## 6. Self-Contained References
Check the `references/` folder for:
- `BeforeAfterExample.sol`: A sample contract before and after FHEVM transformation.
- `MigrationCheatSheet.md`: Side-by-side comparison of standard vs FHEVM code.
- `README.md`: Tools and scripts to automate type conversion.
