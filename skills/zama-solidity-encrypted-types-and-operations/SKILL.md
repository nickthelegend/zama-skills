---
name: Zama Solidity Encrypted Types and Operations
description: The ultimate guide to mastering FHEVM Solidity types (euint8, euint16, euint32, euint64) and their corresponding arithmetic, logical, and comparison operations.
category: Foundation
difficulty: intermediate
tags: [fhevm, solidity, encryption, types, math]
estimated_time: 3 hours
---

# Zama Solidity Encrypted Types and Operations

Welcome to the definitive guide on FHEVM types. In Zama's FHEVM, you don't work with standard `uint` types for sensitive data. Instead, you use encrypted counterparts that allow for computation without decryption.

## 1. Overview
The core of Zama's FHEVM is the ability to perform homomorphic operations. This means that if you have two ciphertexts $C_1$ and $C_2$ representing $m_1$ and $m_2$, you can compute a new ciphertext $C_3$ that represents $m_1 + m_2$ without ever knowing the values of $m_1$ or $m_2$.

## 2. Prerequisites
- Basic Solidity knowledge.
- Understanding of the EVM.
- Completed the `zama-fhevm-hardhat-quickstart` skill.

## 3. Encrypted Types Reference

FHEVM provides the following encrypted types:

| Type | Range | Gas Cost (Relative) |
| :--- | :--- | :--- |
| `ebool` | true / false | Very Low |
| `euint8` | 0 to 255 | Low |
| `euint16` | 0 to 65,535 | Medium |
| `euint32` | 0 to 4,294,967,295 | High |
| `euint64` | 0 to 1.84e19 | Very High |

### Implementation Note: `externalEuint`
When receiving data from a user, you use `externalEuintX`. This type includes a ZK proof that the user actually knows the plaintext value and that it fits within the specified bit-width.

```solidity
function deposit(externalEuint32 encryptedAmount, bytes calldata proof) public {
    euint32 amount = FHE.fromExternal(encryptedAmount, proof);
    // ...
}
```

## 4. Core Operations

### Arithmetic
- `FHE.add(a, b)`: Addition.
- `FHE.sub(a, b)`: Subtraction.
- `FHE.mul(a, b)`: Multiplication.
- `FHE.div(a, b)`: Division (Note: Div and Rem are expensive).
- `FHE.rem(a, b)`: Remainder.

### Logical
- `FHE.and(a, b)`: Bitwise AND.
- `FHE.or(a, b)`: Bitwise OR.
- `FHE.xor(a, b)`: Bitwise XOR.
- `FHE.not(a)`: Bitwise NOT.

### Comparisons
Comparisons return an `ebool`.
- `FHE.eq(a, b)`: Equal to.
- `FHE.ne(a, b)`: Not equal to.
- `FHE.gt(a, b)`: Greater than.
- `FHE.ge(a, b)`: Greater than or equal to.
- `FHE.lt(a, b)`: Less than.
- `FHE.le(a, b)`: Less than or equal to.

### Selection (The FHE Ternary)
Since you cannot use `if (encryptedValue)`, you must use `FHE.select`.
```solidity
// Standard: if (a > b) { result = x; } else { result = y; }
// FHEVM:
ebool condition = FHE.gt(a, b);
euint32 result = FHE.select(condition, x, y);
```

## 5. Security Considerations
- **Information Leaks**: Be careful not to leak data through public events or return values.
- **Side Channels**: Avoid logic that branches on encrypted data (which is impossible anyway, but trying to bypass it with decryption is dangerous).
- **ACL**: Always use `FHE.allow()` to grant permission for the Gateway/KMS to work with specific ciphertexts.

## 6. Gas Optimization Tips
- **Bitwise Shifts**: Use `FHE.shl` and `FHE.shr` for power-of-two multiplication/division.
- **Type Selection**: Don't use `euint64` if `euint32` suffices. The gas difference is significant.
- **Batching**: Use the batching patterns in the `zama-batch-fhe-operations` skill.

## 7. Common Pitfalls & Solutions
- **Reverts**: FHE operations do not revert on overflow/underflow in the same way as Solidity 0.8. They wrap around (standard C-style). Use `FHE.min` and `FHE.max` to implement safe math.
- **Decryption Latency**: Remember that `FHE.requestDecryption` is asynchronous. Plan your UI and contract logic accordingly.

## 8. Full Implementation Example
```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/lib/ZamaEthereumConfig.sol";

contract EncryptedMath is ZamaEthereumConfig {
    euint32 private _secretValue;

    function setSecret(externalEuint32 val, bytes calldata proof) public {
        _secretValue = FHE.fromExternal(val, proof);
        FHE.allowThis(_secretValue);
    }

    function addSecret(externalEuint32 val, bytes calldata proof) public returns (euint32) {
        euint32 input = FHE.fromExternal(val, proof);
        _secretValue = FHE.add(_secretValue, input);
        FHE.allowThis(_secretValue);
        return _secretValue;
    }
}
```

## 9. Self-Contained References
Check the `references/` folder for:
- `FHE.sol`: The core library interface.
- `FHEVMConfig.sol`: Network configuration patterns.
- `MathTest.ts`: Unit tests for homomorphic arithmetic.
