---
name: Zama Security Auditing and Best Practices
description: The master guide to auditing FHEVM smart contracts. Learn to identify side-channel leaks, information leakage via cleartext branching, and ACL misconfigurations.
category: Security
difficulty: advanced
tags: [fhevm, security, auditing, best-practices, privacy]
estimated_time: 5 hours
---

# Zama Security Auditing and Best Practices

Developing on FHEVM requires a "privacy-first" mindset. Standard Solidity patterns can often leak sensitive data when applied to encrypted types. This guide is your checklist for building secure, leak-proof confidential applications.

## 1. Overview
FHEVM security isn't just about preventing hacks; it's about preventing **information leakage**. A contract can be "secure" from a theft perspective but completely fail at its "confidentiality" requirement.

## 2. Core Security Pillars

### Pillar 1: No Cleartext Branching on Secrets
This is the #1 mistake. Never use a decrypted value to decide the execution path in a way that is observable.

```solidity
// ❌ DANGEROUS: Leaks whether the value is > 100 via the execution path
function check(euint32 val) public {
    uint32 clearVal = FHE.decrypt(val);
    if (clearVal > 100) {
        doSomething();
    }
}

// ✅ SECURE: Uses branchless logic
function check(euint32 val) public {
    ebool condition = FHE.gt(val, FHE.asEuint32(100));
    // Perform actions based on 'condition' using FHE.select
}
```

### Pillar 2: Access Control List (ACL) Integrity
Every encrypted handle is protected by the Zama ACL. If you don't call `FHE.allow()`, the Gateway/KMS will refuse to process the ciphertext.

- **Check**: Are you calling `FHE.allowThis()` for every state variable change?
- **Check**: Are you properly scoping permissions for users?

### Pillar 3: Input Validation (Proofs)
Always validate that the user's `externalEuint` comes with a valid proof.

```solidity
function setSecret(externalEuint32 val, bytes calldata proof) public {
    // This library call implicitly validates the proof
    euint32 secret = FHE.fromExternal(val, proof);
}
```

## 3. Common Attack Vectors

### Attack 1: Reentrancy on Callbacks
`FHE.requestDecryption` triggers an asynchronous callback. If that callback performs external calls, it is vulnerable to reentrancy.

### Attack 2: Side-Channel via Gas
While Zama operations have fixed gas costs, the *number* of operations can still leak data if it varies based on user input.

### Attack 3: Information Leakage via Events
Events are public. Never log an encrypted handle or, worse, a decrypted secret in an event.

## 4. Auditing Checklist

1.  **[ ] Control Flow**: Search for all instances of `decrypt` or `requestDecryption`. Ensure the results are not used in `if`, `while`, or `for` loops.
2.  **[ ] ACL**: Verify that every variable assigned to storage has an accompanying `FHE.allowThis()` call.
3.  **[ ] Data Types**: Ensure that the smallest sufficient type is used (e.g., `euint8` instead of `euint32` for small counters) to minimize attack surface and gas.
4.  **[ ] External Calls**: Check that decryption callbacks are protected by `msg.sender == gatewayAddress`.

## 5. Security Snippets

### Secure Callback Guard
```solidity
function decryptionCallback(uint256 requestId, uint32 result) public {
    require(msg.sender == address(gateway), "Only Gateway");
    // ...
}
```

## 6. Self-Contained References
Check the `references/` folder for:
- `VulnerableContract.sol`: A sample contract with intentional leaks for practice.
- `SecurityReport.md`: A template for performing an FHEVM security audit.
- `README.md`: Best practices for secret management in CI/CD.
