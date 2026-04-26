---
name: Zama Best Practices and Common Pitfalls
description: Essential tips and warnings for developing confidential applications on FHEVM to avoid security leaks and performance issues
category: blockchain
tags: [fhevm, best-practices, security, pitfalls]
---

# Zama Best Practices and Common Pitfalls

Developing with FHE (Fully Homomorphic Encryption) requires a different mindset than traditional smart contract development.

## 1. Best Practices

### Optimize FHE Operations
FHE operations are significantly more expensive than standard EVM operations.
- **Batching**: Perform as many operations as possible in a single transaction.
- **Off-chain Precomputation**: If a value doesn't need to be encrypted until a certain point, keep it in cleartext or handle it off-chain.

### Proper ACL Management
Always use `FHE.allowThis` and `FHE.allow` correctly.
- **Ephemeral vs. Permanent**: Remember that `FHE.allowThis` within a function only grants ephemeral permission unless explicitly called for a state variable.
- **Least Privilege**: Only grant decryption permission to the specific users who need it.

### Use the Right Types
Choose the smallest `euint` type that fits your needs (e.g., `euint8` instead of `euint32`) to save on gas and computation time.

## 2. Common Pitfalls

### Pitfall 1: Leaking Information via Control Flow
You **cannot** use an encrypted boolean in a standard `if` statement.
```solidity
// ❌ WRONG: This will not compile or work as expected
if (encryptedBool) { 
    doSomething();
}

// ✅ RIGHT: Use FHE.select
euint32 result = FHE.select(encryptedBool, valTrue, valFalse);
```

### Pitfall 2: Forgetting Input Proofs
Every `externalEuint` passed to a contract MUST be accompanied by a valid cryptographic proof. Without it, the contract cannot verify the ciphertext.

### Pitfall 3: Re-using Handles without Permission
If you receive a ciphertext handle from another contract, you cannot perform operations on it unless that contract has granted your contract permission via `FHE.allow`.

### Pitfall 4: Assuming Instant Decryption
Decryption on a live network (like Sepolia) involves the Zama Gateway and KMS, which takes time (several blocks). Your frontend must handle this asynchronous process and not expect immediate results.

### Pitfall 5: Mixing Encrypted and Cleartext in Comparisons
While you can add a cleartext `uint` to an `euint`, comparisons between encrypted and cleartext values must be handled carefully using the `FHE` library.

## 3. Security Checklist
- [ ] Are all sensitive state variables using `euint` types?
- [ ] Is `FHE.allow` used only for authorized recipients?
- [ ] Are you using `FHE.select` instead of `if` for encrypted conditions?
- [ ] Have you tested your contract against the FHEVM mock environment?
