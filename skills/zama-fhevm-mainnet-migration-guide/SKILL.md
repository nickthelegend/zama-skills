---
name: Zama FHEVM Mainnet Migration Guide
description: The definitive roadmap for moving Zama FHEVM applications from Sepolia testnet to production on Zama Mainnet. Covers security audits, gas budgeting, and infra setup.
category: Operations
difficulty: advanced
tags: [fhevm, mainnet, migration, production, deployment]
estimated_time: 10 hours
---

# Zama FHEVM Mainnet Migration Guide

Deploying to mainnet is the ultimate milestone for any Zama FHEVM project. Unlike testnet, mainnet has real capital at stake, higher gas costs, and strict performance requirements. This guide prepares you for a smooth transition.

## 1. Overview
The migration process involves four key areas:
1.  **Security Audit**: Mandatory verification of confidentiality and logic.
2.  **Infrastructure**: Setting up production-grade Relayers and Gateways.
3.  **Gas Budgeting**: Accurately estimating production costs.
4.  **KMS Configuration**: Ensuring correct public key management for the mainnet KMS.

## 2. Prerequisites
- A fully tested application on the Zama Sepolia devnet.
- Completed the `zama-security-auditing` and `zama-fhevm-gas-optimization` skills.

## 3. The Migration Roadmap

### Phase 1: Production Security Audit
Before mainnet, you **must** perform a professional audit. Focus on:
- Side-channel leaks via `FHE.select` patterns.
- Proper ACL permissioning (`FHE.allowThis`).
- Input proof validation for all `externalEuint` types.

### Phase 2: Gas and Economics
Mainnet gas prices can fluctuate wildly.
- **Budgeting**: Calculate the "Worst Case" gas cost for FHE operations.
- **Relayer Fees**: Set up a mechanism to compensate relayers for the gas they spend on decryption callbacks.

### Phase 3: Infrastructure Setup
Don't rely on public Gateways for production.
- **Private Gateway**: Deploy your own Gateway instance for better reliability and lower latency.
- **Dedicated KMS Access**: Ensure your contract is whitelisted (if required) on the production KMS network.

### Phase 4: Deployment
Deploy your contracts using a secure hardware wallet (e.g., Ledger/Trezor).

```bash
npx hardhat deploy --network zama-mainnet
```

## 4. Mainnet Specifics

| Feature | Sepolia (Testnet) | Zama Mainnet (Production) |
| :--- | :--- | :--- |
| **Gas Limit** | Flexible | Strict (per block) |
| **KMS Nodes** | Shared / Dev | Decentralized / High-Availability |
| **Gateway** | Public | Recommended Private / Dedicated |
| **Privacy** | Simulated | Full Homomorphic Encryption |

## 5. Post-Deployment Monitoring
Once live, monitor:
- **Decryption Latency**: Track the time between request and callback.
- **KMS Errors**: Watch for any MPC consensus failures.
- **Gas Usage**: Use tools like Blockscout to analyze encrypted transaction efficiency.

## 6. Common Pitfalls & Solutions
- **Pitfall**: Hardcoded Sepolia addresses (ACL, Gateway).
- **Solution**: Use a configuration manager like `FHEVMConfig.sol` that detects the network at deployment time.

## 7. Self-Contained References
Check the `references/` folder for:
- `ProductionConfig.ts`: Optimized Hardhat config for mainnet.
- `MigrationChecklist.md`: A 50-point checklist for production readiness.
- `SecurityAuditTemplate.md`: Guide for your audit team.
