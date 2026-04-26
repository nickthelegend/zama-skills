---
name: Zama Relayer SDK Frontend Integration
description: The masterclass in connecting React frontends to Zama FHEVM using the Relayer SDK and fhevmjs. Learn to encrypt inputs, handle signatures, and perform private decryption.
category: Frontend
difficulty: advanced
tags: [fhevm, react, relayer-sdk, fhevmjs, frontend]
estimated_time: 4 hours
---

# Zama Relayer SDK Frontend Integration

Integrating FHE into a web application is the final frontier of private blockchain development. This guide covers the end-to-end flow of interacting with encrypted data from a browser.

## 1. Overview
The frontend must handle three critical tasks:
1.  **Encryption**: Encrypting user inputs before sending them to the blockchain.
2.  **Signature Management**: Signing requests to allow the Relayer to fetch decrypted data on the user's behalf.
3.  **Decryption**: Interfacing with the Zama Gateway and KMS via the Relayer SDK to reveal data privately.

## 2. Prerequisites
- Familiarity with React and Wagmi/Viem.
- A deployed FHEVM contract on Sepolia.
- Completed the `zama-fhevm-hardhat-quickstart` skill.

## 3. Installation

You need `fhevmjs` for client-side encryption and the Relayer SDK for decryption.

```bash
npm install fhevmjs @fhevm/sdk
```

## 4. Initializing the FHEVM Instance

The `fhevmjs` instance requires the KMS public key, which you can fetch from the Gateway.

```typescript
import { createInstance } from "fhevmjs";

async function getFhevmInstance(chainId: number) {
  // Fetch public key from Zama Gateway
  const response = await fetch("https://gateway.sepolia.zama.ai/pubkey");
  const { publicKey } = await response.json();

  return await createInstance({
    chainId,
    publicKey,
  });
}
```

## 5. Encrypting Inputs

When a user wants to send a private value, the frontend encrypts it and generates a ZK proof.

```typescript
async function encryptValue(instance: any, contractAddress: string, userAddress: string, value: number) {
  const input = instance.createEncryptedInput(contractAddress, userAddress);
  input.add32(value);
  const encrypted = await input.encrypt();
  
  return {
    handle: encrypted.handles[0],
    proof: encrypted.inputProof,
  };
}
```

## 6. Private Decryption Flow

To see their own encrypted balance, a user must sign a message. This signature is then sent to the Relayer, which interacts with the KMS to get the result.

### Step 1: Request a Signature
```typescript
const { signature, publicKey } = await instance.generatePublicKey(contractAddress);
```

### Step 2: Fetch the Decrypted Result
```typescript
const result = await sdk.reencrypt(
  handle,
  instance.privateKey,
  publicKey,
  signature,
  contractAddress,
  userAddress
);
```

## 7. Security Considerations
- **Private Key Storage**: Never store the `fhevmjs` private key on a server. It must stay in the user's browser memory.
- **Phishing**: Users should only sign decryption requests for contracts they trust.
- **Relayer Trust**: The Relayer SDK is designed so the Relayer itself cannot see the decrypted data (it's encrypted for the user's ephemeral key).

## 8. Gas Optimization Tips
- **Minimize Re-encryptions**: Re-encryption is a heavy operation for the KMS. Only re-encrypt when the user actually needs to see the value.
- **Caching**: Cache the FHEVM instance and public key to avoid redundant network requests.

## 9. Common Pitfalls & Solutions
- **WASM Issues**: `fhevmjs` uses WASM. Ensure your build tool (Vite/Webpack) is configured to handle `.wasm` files and large assets.
- **ChainId Mismatch**: The encryption public key is specific to the chainId. Ensure they match.

## 10. Full React Hook Example
```typescript
import { useState, useEffect } from 'react';
import { createInstance } from 'fhevmjs';

export function useFhevm() {
  const [instance, setInstance] = useState(null);

  useEffect(() => {
    const init = async () => {
      const inst = await getFhevmInstance(11155111);
      setInstance(inst);
    };
    init();
  }, []);

  return instance;
}
```

## 11. Self-Contained References
Check the `references/` folder for:
- `relayer-sdk-core.ts`: Implementation of the decryption client.
- `useFHECounterWagmi.tsx`: A complete React hook for a counter dapp.
- `README.md`: Setup instructions for Vite/Next.js.
