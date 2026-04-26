---
name: Zama React Frontend Template
description: Premium guide to building encrypted UIs using Zama's React template, Wagmi, and the FHEVM SDK. Self-contained with hooks and provider examples.
category: frontend
tags: [fhevm, react, nextjs, wagmi, tailwind, frontend]
---

# Zama React Frontend Template

This guide shows how to build a modern, encrypted frontend for your FHEVM dApps using Zama's official React template.

## 1. Setup

The template uses Next.js, Wagmi, and Tailwind CSS.

```bash
git clone https://github.com/zama-ai/fhevm-react-template.git
cd fhevm-react-template
pnpm install
```

## 2. FHEVM Provider Initialization

You must initialize the FHEVM instance to handle client-side encryption.

```typescript
import { createRelayerFhevm } from "@fhevm/sdk";

const fhevm = await createRelayerFhevm({
  chainId: 11155111,
  rpcUrl: "https://sepolia.infura.io/v3/YOUR_KEY",
  relayerUrl: "https://relayer.sepolia.zama.ai",
});
```

## 3. Custom Hooks for FHEVM

The template includes helpful hooks like `useFHECounterWagmi.tsx` to simplify contract interactions.

### Example: Encrypting User Input
```typescript
const { createEncryptedInput } = useFHE();

const handleIncrement = async (value: number) => {
  const input = await createEncryptedInput(contractAddress, userAddress)
    .add32(value)
    .encrypt();
    
  await contract.increment(input.handles[0], input.inputProof);
};
```

### Example: Decrypting Authorized Data
```typescript
const { userDecryptEuint } = useFHE();

const fetchSecretValue = async () => {
  const handle = await contract.getSecret();
  const clearValue = await userDecryptEuint(
    FhevmType.euint32,
    handle,
    contractAddress,
    userSigner
  );
  setSecret(clearValue);
};
```

## 4. UI Components

Use standard React patterns to display cleartext data after decryption. Always handle loading states as decryption via the Gateway takes time.

```tsx
return (
  <div className="card bg-base-100 shadow-xl">
    <div className="card-body">
      <h2 className="card-title">Encrypted Counter</h2>
      <p>Value: {isLoading ? <span className="loading loading-spinner"></span> : count}</p>
      <button onClick={() => handleIncrement(1)} className="btn btn-primary">
        Increment Confidential
      </button>
    </div>
  </div>
);
```

## 5. Self-Contained References
Check the `references/` folder for:
- `useFHECounterWagmi.tsx`: Example hook for contract interaction.
- `wagmiConfig.tsx`: Web3 configuration.
- `FHECounter.ts`: TypeScript contract interface.
- `globals.css`: Tailwind styling base.
