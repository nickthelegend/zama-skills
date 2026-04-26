---
name: Zama Relayer SDK Frontend Integration
description: Guide to integrating Zama's Relayer SDK into your frontend application to handle encrypted inputs and decryptions
category: frontend
tags: [relayer-sdk, javascript, typescript, encryption, decryption]
---

# Zama Relayer SDK Frontend Integration

The Relayer SDK allows your frontend application to interact with FHEVM smart contracts by handling encryption and decryption processes seamlessly.

## 1. Installation

Install the Relayer SDK in your project:

```bash
npm install @fhevm/sdk
```

## 2. Initialization

Initialize the SDK with the FHEVM host chain configuration:

```typescript
import { createRelayerFhevm } from "@fhevm/sdk";

const fhevm = await createRelayerFhevm({
  chainId: 11155111, // Sepolia
  rpcUrl: "https://sepolia.infura.io/v3/YOUR_KEY",
  relayerUrl: "https://relayer.sepolia.zama.ai",
});
```

## 3. Creating Encrypted Inputs

To send encrypted data to a smart contract, you must first create an encrypted input. This process handles the encryption and generates a cryptographic proof.

```typescript
const instance = await fhevm.createEncryptedInput(
  contractAddress,
  userAddress
);

// Add values to encrypt
instance.add8(42); // For euint8
instance.add32(1337); // For euint32

// Encrypt and get the result
const encryptedInput = await instance.encrypt();

// Use these in your contract call
const handle = encryptedInput.handles[0];
const proof = encryptedInput.inputProof;

await contract.myMethod(handle, proof);
```

## 4. User Decryption

If a contract has granted you permission to view an encrypted value (via ACL), you can decrypt it using the SDK.

```typescript
const encryptedValue = await contract.getEncryptedValue();

const clearValue = await fhevm.userDecryptEuint(
  FhevmType.euint32,
  encryptedValue,
  contractAddress,
  userSigner
);

console.log("Decrypted value:", clearValue);
```

## 5. Public Decryption

For values that are publicly decryptable:

```typescript
const clearValue = await fhevm.publicDecryptEuint(
  FhevmType.euint32,
  encryptedValue,
  contractAddress
);
```

## 6. Best Practices

- **Caching**: Reuse the `fhevm` instance across your application.
- **Error Handling**: Always handle potential encryption/decryption failures.
- **Provider Choice**: Use a reliable RPC provider for consistent state checks.
