# Zama AI Agents - v3.0 Advanced Configuration

This repository is a production-grade knowledge base optimized for AI agents.

## Advanced Patterns for Agents

### Pattern 1: Refactor Public Contract to FHEVM
**Prompt**: "Use the `zama-solidity-transformation` skill to identify all sensitive state in this contract. Refactor the logic to use `euint` types and `FHE.select`. Ensure all inputs are changed to `externalEuint` + proofs."

### Pattern 2: Add Decryption Flow
**Prompt**: "I need to reveal the winner of this auction. Use the `zama-acl-kms-decryption` and `zama-reentrancy-protection` skills to implement a secure `FHE.requestDecryption` flow with a guarded callback."

### Pattern 3: Optimize Gas for FHE
**Prompt**: "This contract is too expensive. Use the `zama-fhevm-gas-optimization` and `zama-batch-fhe-operations` skills to reduce the number of FHE operations and batch the permission calls."

## Agent Rules
1. **Always** check `references/` for actual contract code before generating a new implementation.
2. **Never** assume a standard Solidity pattern (like mapping lookup) is private without using `euint`.
3. **Always** implement `FHE.allowThis()` for state persistence.
