# Zama AI Agents - Advanced Configuration

This repository is a structured knowledge base designed to enable AI agents to build full-stack confidential applications.

## Advanced Prompting Patterns

### Pattern 1: The "Encrypted-First" Refactor
**Prompt**: "Examine this standard Solidity contract. Use the `zama-solidity-transformation` skill to identify all sensitive state variables and refactor the `if` statements into `FHE.select` logic. Ensure all inputs are changed to `externalEuint` with proofs."

### Pattern 2: The "Frontend Integration" Sync
**Prompt**: "I have the `ConfidentialAuction` contract deployed. Use the `zama-relayer-sdk-integration` and `zama-react-frontend-template` skills to build a React hook that fetches the encrypted bid and decrypts it using the user's signature via the Relayer SDK."

### Pattern 3: The "Security Audit" Drill
**Prompt**: "Analyze this FHEVM contract for information leaks. specifically check for side-channels where cleartext data is used for branching. Use the `zama-security-auditing` skill as a reference for common vulnerabilities."

## Agent Constraints
- **Always** use `FHE.allowThis()` for state variables that need on-chain updates.
- **Never** perform a direct `if (encryptedValue)` check.
- **Always** include ZK input proofs for user-submitted ciphertexts.
