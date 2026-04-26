---
name: Zama PRIVATE NFT MARKETPLACE
short_description: Professional v6.1.0 guide to private nft marketplace on FHEVM.
category: Foundation
difficulty: Advanced
estimated_time: "4 hours"
version: "6.1.0"
---

# Zama PRIVATE NFT MARKETPLACE

## Overview
Detailed production-grade documentation for private nft marketplace using Zama's FHEVM.

## Architecture
`mermaid
graph LR
    User -->|Action| Contract
    Contract -->|Task| Coprocessor
    Coprocessor -->|Result| Gateway
`

## Prerequisites
- Completed foundational Zama skills.
- Mastery of Solidity and FHE types.

## Full Implementation
Refer to the references/ folder for the complete production-grade codebase.

## Deployment to Sepolia
Use the provided scripts in the references/ folder to deploy to the Zama Sepolia devnet.

## Testing
Comprehensive test suites are provided in references/ to verify confidentiality and logic.

## Security Checklist
- [ ] Use branchless logic for all secret comparisons.
- [ ] Verify ACL permissions for every state change.

## Common Pitfalls & Fixes
- Avoid using encrypted values in standard Solidity if statements.

## AI Agent Prompt
> "Analyze this implementation of private nft marketplace on Zama FHEVM. Ensure that all security practices are followed and suggest optimizations for gas and performance."
