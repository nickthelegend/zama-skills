---
name: Zama Security Auditing Best Practices
description: Premium guide for auditing FHEVM smart contracts. Learn to identify side-channel leaks, ACL misconfigurations, and logic errors unique to homomorphic encryption.
category: security
tags: [fhevm, security, audit, best-practices, privacy]
---

# Zama Security Auditing Best Practices

Auditing FHEVM contracts requires looking beyond standard Solidity vulnerabilities like reentrancy. You must ensure that no sensitive data "leaks" through cleartext side-channels.

## 1. Information Leakage via Control Flow

The most common security flaw in FHEVM is leaking information through `if` statements or `require` checks that depend on cleartext data derived from encrypted state.

### Vulnerability: Branching on Decrypted Data
```solidity
// ❌ VULNERABLE
function checkBalance(address user) public {
    uint32 clearBalance = FHE.decrypt(balances[user]); // Decrypting on-chain!
    if (clearBalance > 1000) {
        doSomethingSpecial();
    }
}
```
**Risk**: Anyone can observe which branch was taken by looking at gas consumption or state changes, effectively learning if the balance is > 1000.

### Fix: Use `FHE.select`
```solidity
// ✅ SECURE
function checkBalance(address user) public {
    ebool isHigh = FHE.gt(balances[user], 1000);
    // Logic remains encrypted
    state = FHE.select(isHigh, val1, val2);
}
```

## 2. ACL and Permission Leaks

Every `euint` handle has an Access Control List (ACL). If you grant permission to the wrong address, they can decrypt the value via the Gateway.

### Audit Checklist for ACL
- [ ] Is `FHE.allow` used only for the intended recipient?
- [ ] Is `FHE.allowThis` used for all state variables that the contract needs to operate on?
- [ ] Are you using `FHE.allowTransient` for values passed between contracts?

## 3. Input Validation Side-Channels

If a contract reverts based on an encrypted input's property (e.g., "invalid proof"), it might leak info.

### The "Silent Failure" Pattern
Zama's `ConfidentialERC20` often uses silent failures (transferring 0 instead of reverting) to prevent leaking whether a user had enough balance.

**Auditor's Tip**: Look for `require` statements. If they depend on data that should be secret, they are a red flag.

## 4. Replay Attacks with Ciphertexts

Ciphertexts (handles) should ideally be unique or handled carefully to prevent an attacker from re-submitting a previously used handle to "replay" an action.

## 5. Decryption Oracle Misuse

Functions that trigger `FHE.requestDecryption` must be heavily guarded.

- [ ] Is the decryption request triggered only after a specific condition (e.g., auction end)?
- [ ] Is the callback function `internal` or guarded by a `requestId` check?

## 6. Self-Contained References
Check the `references/` folder for:
- `SecurityChecklist.md`: Detailed list for auditors.
- `VulnerableContract.sol`: Example of what NOT to do.
- `SecureContract.sol`: The secure version of the same logic.
