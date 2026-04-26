---
name: Transforming Solidity to FHEVM
description: Premium guide for developers migrating existing Solidity contracts to FHEVM. Learn to identify sensitive state, replace if-statements with FHE.select, and manage ACLs.
category: blockchain
tags: [fhevm, solidity, migration, refactoring, security]
---

# Transforming Solidity to FHEVM

Migrating a standard contract to FHEVM isn't just about changing `uint` to `euint`. It requires a fundamental shift in how logic is structured.

## 1. Identify Sensitive State

Look for `private` or `internal` variables that contain user data. In standard Solidity, these are still readable via `getStorageAt`. In FHEVM, they should be `euint`.

```solidity
// Standard
uint256 private _userBalance;

// FHEVM
euint32 private _userBalance;
```

## 2. Refactor Control Flow

Standard `if` statements cannot use encrypted booleans. You must refactor to branchless logic using `FHE.select`.

```solidity
// ❌ Standard logic
if (balance >= price) {
    balance -= price;
}

// ✅ FHEVM logic
ebool canAfford = FHE.ge(balance, price);
balance = FHE.sub(balance, FHE.select(canAfford, price, FHE.asEuint32(0)));
```

## 3. Implement Input Proofs

External inputs that were previously `uint` must now be `externalEuint` + `proof`.

```solidity
// Standard
function deposit(uint256 amount) public;

// FHEVM
function deposit(externalEuint32 amount, bytes calldata proof) public;
```

## 4. Handle Access Control

Standard `public` view functions won't work for encrypted data. You must implement the Zama ACL pattern and use the Relayer SDK for decryption.

## 5. Self-Contained References
Check the `references/` folder for:
- `MigrationCheatSheet.md`: Side-by-side comparison of standard vs FHEVM code.
- `BeforeAfterExample.sol`: A contract before and after FHEVM transformation.
