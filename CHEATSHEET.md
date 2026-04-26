# Zama FHEVM Elite Cheat Sheet (v5.0)

The ultimate quick-reference for Zama FHEVM architects.

## 1. Coprocessor Native Opcodes

| Hex | Mnemonic | Gas Weight |
| :--- | :--- | :--- |
| `0x01` | `ADD` | 1.0x |
| `0x02` | `SUB` | 1.0x |
| `0x03` | `MUL` | 4.5x |
| `0x04` | `SEL` | 2.0x |
| `0x05` | `SHL` | 0.8x |

## 2. Infrastructure (Sepolia)

- **Gateway**: `https://gateway.sepolia.zama.ai`
- **ACL**: `0x848B0066793BcC60346Da1F49049357399B8D595`
- **KMS PubKey**: `https://gateway.sepolia.zama.ai/pubkey`

## 3. Security Patterns
- **MEV Protection**: Always encrypt the `amount` and `slippage` in DEX trades to prevent front-running by searchers.
- **Key Rotation**: For high-value contracts, implement a `rotateKey()` function that requests a new re-encryption handle from the KMS.

## 4. FHE Math Quick-Ref
- **Addition**: `FHE.add(a, b)`
- **Ternary**: `FHE.select(ebool, x, y)`
- **Comparison**: `FHE.le(a, b)` (Less than or equal)

## 5. Mainnet Checklist
- [ ] Gas costs optimized (use `euint8` where possible).
- [ ] No side-channel leaks via `if (cleartext)`.
- [ ] Reentrancy guards on all decryption callbacks.
