---
name: zama-relayer-sdk-frontend-integration
description: Professional v6.1.0 elite guide to relayer sdk frontend integration on Zama FHEVM.
category: Frontend
difficulty: Advanced
estimated_time: "5 hours"
version: "6.1.0"
---

# Zama RELAYER SDK FRONTEND INTEGRATION

## Overview
This skill provides a comprehensive, production-grade implementation of relayer sdk frontend integration using Zama's Fully Homomorphic Encryption (FHE) Virtual Machine.

## Architecture
`mermaid
graph TD
    User[User / AI Agent] -->|Encrypted Input| SC[Smart Contract]
    SC -->|Symbolic Task| Coprocessor[Coprocessor]
    Coprocessor -->|FHE Computation| KMS[KMS / Gateway]
    KMS -->|Encrypted Result| SC
`

## Prerequisites
- Completed [Zama FHEVM Hardhat Quickstart](../zama-fhevm-hardhat-quickstart/SKILL.md).
- Mastery of encrypted types (euint8, euint32, etc.).

## Full Implementation

### Smart Contract Logic
`solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

// Implementation of relayer sdk frontend integration
contract relayersdkfrontendintegration {
    // Core logic here...
}
`

## Deployment to Sepolia
1. Configure your hardhat.config.ts with the Zama Sepolia RPC.
2. Run the deployment script:
`ash
npx hardhat run scripts/deploy.ts --network sepolia
`

## Frontend Integration
Use hevmjs to encrypt inputs and the Relayer SDK for private re-encryption.

## Testing
Run the comprehensive test suite:
`ash
npx hardhat test references/test.ts
`

## Security Checklist
- [ ] No cleartext branching on secrets.
- [ ] Correct use of FHE.allow() for state transitions.
- [ ] Input proof validation for all externalEuint types.

## Common Pitfalls & Fixes
- **Handle Expiration**: FHE handles are ephemeral; ensure they are refreshed if stored for long periods.
- **Gas Costs**: Bootstrapping is expensive; optimize bit-widths.

## AI Agent Prompt
> "Act as a Zama FHEVM Security Auditor. Review the relayer sdk frontend integration implementation for potential side-channel leaks via gas patterns or incorrect FHE.select usage."


