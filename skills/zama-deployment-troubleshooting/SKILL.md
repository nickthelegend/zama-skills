---
name: Zama Deployment Troubleshooting
description: Premium guide to resolving common errors when deploying and interacting with FHEVM. Covers Gateway issues, proof failures, and gas optimization.
category: blockchain
tags: [fhevm, debugging, troubleshooting, deployment, sepolia]
---

# Zama Deployment Troubleshooting

Deploying FHEVM contracts involves more moving parts than standard EVM apps (Gateway, KMS, Relayers). This guide helps you identify and fix the most common issues.

## 1. Common Error: "Proof verification failed"

This occurs when the `inputProof` provided to an `externalEuint` function is invalid.

### Causes:
- **Wrong Public Key**: You used a public key from a different network (e.g., used Mock key on Sepolia).
- **Mismatched Handle**: The proof was generated for a different value than the one passed in `externalEuint`.
- **Clock Drift**: Significant time difference between your local machine and the network.

### Fix:
Ensure you are fetching the network's public key dynamically:
```typescript
const publicKey = await fhevm.getPublicKey(contractAddress);
const input = await fhevm.createEncryptedInput(contractAddress, userAddress)
  .add32(val)
  .encrypt();
```

## 2. Common Error: "Gateway timeout" or "Decryption failed"

Decryptions go through the Zama Gateway and KMS.

### Causes:
- **No ACL Permission**: You forgot to call `FHE.allow` or `FHE.allowThis` for the handle.
- **Gateway Congestion**: The Sepolia Gateway might be under heavy load.
- **Expired Handle**: Handles can expire if not used within a certain timeframe (usually several hours).

### Fix:
Verify your ACL calls in Solidity:
```solidity
FHE.allow(secret, authorizedUser);
FHE.allowThis(secret);
```

## 3. Common Error: "Transaction ran out of gas"

FHE operations are gas-intensive.

### Fixes:
- **Increase Gas Limit**: Manually set a higher gas limit in your Hardhat config or transaction options.
- **Optimize Types**: Use `euint8` or `euint16` instead of `euint32` if possible.
- **Batching**: Reduce the number of `FHE.allow` calls by batching operations.

## 4. Environment-Specific Issues

### Local Node (Anvil/Mock)
- **State Not Reset**: If your local node crashes, the mock state might become inconsistent. Restart Anvil with a clean state.
- **Plugin Version**: Ensure `@fhevm/hardhat-plugin` is up to date.

### Sepolia
- **Faucet Limits**: If you run out of Sepolia ETH, use [faucet.zama.ai](https://faucet.zama.ai/).
- **Network Lag**: Remember that decryptions take several blocks. Do not poll too aggressively.

## 5. Debugging Tools
- **Zama Explorer**: Use the Zama-specific block explorer to view FHE-related events.
- **Console Logs**: Use `hardhat-console.sol` (standard) for cleartext parts of your contract.
- **Mock Mode**: Always verify your logic in `isMock: true` mode first.

## 6. Self-Contained References
Check the `references/` folder for:
- `TroubleshootingGuide.md`: Expanded list of error codes and solutions.
- `DebugScripts.ts`: Scripts to verify Gateway connectivity and ACL permissions.
