---
name: Zama Solidity Encrypted Types and Operations
description: Comprehensive guide to using FHEVM encrypted types (euint8, euint16, etc.) and performing arithmetic and logic operations in Solidity
category: blockchain
tags: [fhevm, solidity, encryption, types]
---

# Zama Solidity Encrypted Types and Operations

This skill covers the available encrypted types in Zama's FHEVM and how to perform operations on them.

## 1. Encrypted Types

FHEVM provides several encrypted unsigned integer types:

| Type | Description |
| --- | --- |
| `ebool` | Encrypted boolean |
| `euint8` | Encrypted 8-bit unsigned integer |
| `euint16` | Encrypted 16-bit unsigned integer |
| `euint32` | Encrypted 32-bit unsigned integer |
| `euint64` | Encrypted 64-bit unsigned integer |
| `euint128` | Encrypted 128-bit unsigned integer |
| `euint256` | Encrypted 256-bit unsigned integer |

There are also "external" counterparts used for user inputs: `externalEuint8`, `externalEuint16`, etc.

## 2. Basic Arithmetic Operations

Arithmetic operations are performed using the `FHE` library. These operations take encrypted types as input and return an encrypted result.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

// Addition
euint32 sum = FHE.add(a, b);

// Subtraction
euint32 diff = FHE.sub(a, b);

// Multiplication
euint32 product = FHE.mul(a, b);

// Division
euint32 quotient = FHE.div(a, b);

// Remainder (Modulo)
euint32 rem = FHE.rem(a, b);
```

## 3. Bitwise Operations

```solidity
euint32 resAnd = FHE.and(a, b);
euint32 resOr = FHE.or(a, b);
euint32 resXor = FHE.xor(a, b);
euint32 resShl = FHE.shl(a, b); // Shift left
euint32 resShr = FHE.shr(a, b); // Shift right
```

## 4. Comparisons

Comparisons return an `ebool`.

```solidity
ebool eq = FHE.eq(a, b);
ebool ne = FHE.ne(a, b);
ebool ge = FHE.ge(a, b);
ebool gt = FHE.gt(a, b);
ebool le = FHE.le(a, b);
ebool lt = FHE.lt(a, b);
```

## 5. Select (If-Then-Else)

Since you cannot use standard `if` statements with encrypted booleans, you must use `FHE.select`.

```solidity
// If condition is true, return valTrue, else return valFalse
euint32 result = FHE.select(condition, valTrue, valFalse);
```

## 6. Example: FHEAdd Contract

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, externalEuint8 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract FHEAdd is ZamaEthereumConfig {
  euint8 private _a;
  euint8 private _b;
  euint8 private _a_plus_b;

  function setA(externalEuint8 inputA, bytes calldata inputProof) external {
    _a = FHE.fromExternal(inputA, inputProof);
    FHE.allowThis(_a);
  }

  function setB(externalEuint8 inputB, bytes calldata inputProof) external {
    _b = FHE.fromExternal(inputB, inputProof);
    FHE.allowThis(_b);
  }

  function computeAPlusB() external {
    _a_plus_b = FHE.add(_a, _b);
    FHE.allowThis(_a_plus_b);
    FHE.allow(_a_plus_b, msg.sender);
  }
}
```
