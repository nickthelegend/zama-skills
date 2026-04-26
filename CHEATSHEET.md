# Zama FHEVM Cheat Sheet (v3.0)

Quick reference for common operations, addresses, and security patterns.

## 1. Core FHE Operators

| Operation | Solidity Code | Description |
| :--- | :--- | :--- |
| **Input** | `FHE.fromExternal(val, proof)` | Convert user input to encrypted type. |
| **Selection** | `FHE.select(ebool, a, b)` | Encrypted `if-else` (ternary). |
| **Shift** | `FHE.shl(a, 2)` | Bitwise shift left (cheap multiplication). |
| **Permission** | `FHE.allow(handle, address)` | Grant decryption rights via Gateway. |
| **Random** | `FHE.random8()` | Generate encrypted random byte (future API). |

## 2. Sepolia Infrastructure

- **Gateway RPC**: `https://rpc.sepolia.zama.ai`
- **Faucet**: `https://faucet.zama.ai`
- **KMS Public Key**: Fetch via Relayer SDK at runtime.

## 3. Security Checklist (v3.0)
- [ ] **No Reverts on Secrets**: Never use `require(encryptedValue)` or `if (encryptedValue)`.
- [ ] **Callback Guards**: Protect `FHE.requestDecryption` callbacks from unauthorized calls.
- [ ] **ACL Management**: Call `FHE.allowThis()` for every state variable change.
- [ ] **Input Proofs**: Always validate ZK proofs for `externalEuint` inputs.
- [ ] **Gas Limits**: FHE operations can consume >10M gas. Test limits on Sepolia.

## 4. Coprocessor Pattern
FHEVM uses symbolic execution. Transactions on-chain produce "pointers" to ciphertexts. The actual computation is offloaded to the coprocessor network, ensuring standard block times are maintained.

## 5. Relayer SDK (TypeScript)
```typescript
const encryptedInput = instance.createEncryptedInput(contractAddress, userAddress)
  .add32(amount)
  .encrypt();

await contract.performAction(
  encryptedInput.handles[0],
  encryptedInput.inputProof
);
```
