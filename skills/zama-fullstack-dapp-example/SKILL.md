---
name: Zama Fullstack DApp Example
description: A complete walkthrough of building an end-to-end encrypted DApp, from Solidity contracts to a React frontend using the Relayer SDK
category: blockchain
tags: [fhevm, fullstack, react, relayer-sdk, solidity]
---

# Zama Fullstack DApp Example

This skill demonstrates how to connect your confidential Solidity contracts with a modern frontend using Zama's fullstack tools.

## 1. Project Structure

A typical Zama fullstack project is organized as a monorepo or two separate directories:

- `/contracts`: Hardhat environment for FHEVM contracts.
- `/frontend`: React/Next.js application using `@fhevm/sdk`.

## 2. Smart Contract (The Backend)

Use the `FHECounter` as our example. It stores an encrypted value and allows authorized users to increment and view it.

```solidity
// contracts/FHECounter.sol
contract FHECounter is ZamaEthereumConfig {
    euint32 private _count;
    // ... increment and getCount logic ...
}
```

## 3. Frontend Integration (The UI)

### Step A: Initialize the FHEVM Instance

```typescript
// frontend/src/fhevm.ts
import { createRelayerFhevm } from "@fhevm/sdk";

export const initFhevm = async () => {
  return await createRelayerFhevm({
    chainId: 11155111,
    rpcUrl: process.env.NEXT_PUBLIC_RPC_URL,
    relayerUrl: "https://relayer.sepolia.zama.ai",
  });
};
```

### Step B: Handle Encrypted Input

When the user clicks "Increment", encrypt the input before sending the transaction.

```typescript
const handleIncrement = async (amount: number) => {
  const fhevm = await initFhevm();
  const input = await fhevm.createEncryptedInput(contractAddress, userAddress)
    .add32(amount)
    .encrypt();

  const tx = await contract.increment(input.handles[0], input.inputProof);
  await tx.wait();
};
```

### Step C: Decrypt and Display Data

To show the current counter value, call the contract and then decrypt the handle using the user's signature.

```typescript
const fetchCount = async () => {
  const encryptedHandle = await contract.getCount();
  const fhevm = await initFhevm();
  
  const clearValue = await fhevm.userDecryptEuint(
    FhevmType.euint32,
    encryptedHandle,
    contractAddress,
    userSigner
  );
  
  setCount(clearValue);
};
```

## 4. Workflow Summary

1.  **User Actions**: The user interacts with the UI.
2.  **Encryption**: The frontend uses `@fhevm/sdk` to encrypt sensitive data locally.
3.  **Transaction**: The encrypted data (handle + proof) is sent to the FHEVM host chain (Sepolia).
4.  **FHEVM Execution**: The contract performs operations on the encrypted data.
5.  **Decryption**: The frontend requests decryption for the authorized user, which involves the Zama Gateway and the Relayer.

## 5. Deployment

1.  Deploy contracts to Sepolia using Hardhat.
2.  Update the frontend `contractAddress` and `rpcUrl`.
3.  Deploy the frontend to a platform like Vercel.
