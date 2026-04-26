# Zama FHEVM Cheat Sheet

Quick reference for common operations, addresses, and best practices.

## 1. Core FHE Operators

| Operation | Solidity Code | Description |
| :--- | :--- | :--- |
| **Input** | `FHE.fromExternal(val, proof)` | Convert user input to encrypted type. |
| **Addition** | `FHE.add(a, b)` | Sum of two encrypted values. |
| **Comparison** | `FHE.ge(a, b)` | Greater than or equal (returns `ebool`). |
| **Selection** | `FHE.select(ebool, a, b)` | Encrypted `if-else` (ternary). |
| **Shift** | `FHE.shl(a, 2)` | Bitwise shift left (cheap multiplication). |
| **Permission** | `FHE.allow(handle, address)` | Grant decryption rights via Gateway. |

## 2. Sepolia Addresses (Official)

- **KMS Public Key**: Fetch dynamically using `fhevm.getPublicKey(contractAddress)`
- **ACL Contract**: `0x...` (See [fhevm.zama.ai](https://fhevm.zama.ai) for latest)
- **Gateway**: Integrated into the Zama Sepolia RPC.

## 3. Relayer SDK Snippets

### Initializing FHEVM
```typescript
import { createInstance } from "fhevmjs";
const instance = await createInstance({ chainId, publicKey });
```

### Creating Encrypted Input
```typescript
const input = instance.createEncryptedInput(contractAddress, userAddress)
  .add32(amount)
  .encrypt();
```

## 4. Best Practices Checklist
- [ ] Use `euint8` for low-range numbers to save gas.
- [ ] Always call `FHE.allowThis(handle)` for state variables.
- [ ] Use `FHE.asEuintX()` for literals (e.g., `FHE.asEuint32(100)`).
- [ ] Implement "Silent Failures" for private balance checks.
