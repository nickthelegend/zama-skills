---
name: Zama Advanced FHE Operations
description: In-depth guide to complex encrypted computations in Solidity using FHEVM. Covers bitwise operations, division/remainder, and advanced branching with FHE.select.
category: blockchain
tags: [fhevm, solidity, math, bitwise, advanced]
---

# Zama Advanced FHE Operations

Beyond simple addition and subtraction, FHEVM supports a wide range of operations that enable complex on-chain logic.

## 1. Bitwise Operations

You can perform bitwise operations on `euint` types just like regular integers.

```solidity
euint32 a = ...;
euint32 b = ...;

euint32 andResult = FHE.and(a, b);
euint32 orResult = FHE.or(a, b);
euint32 xorResult = FHE.xor(a, b);
euint32 shlResult = FHE.shl(a, 2); // Shift left by 2
euint32 shrResult = FHE.shr(a, 1); // Shift right by 1
```

## 2. Advanced Math

FHEVM includes support for division and remainder, though they are more computationally expensive.

```solidity
euint32 quotient = FHE.div(a, b);
euint32 remainder = FHE.rem(a, b);
```

### Min and Max
```solidity
euint32 smaller = FHE.min(a, b);
euint32 larger = FHE.max(a, b);
```

## 3. Complex Branching with `FHE.select`

Since you cannot use `if (encryptedValue)`, you must use `FHE.select` for conditional logic. You can nest these for complex conditions.

```solidity
// Equivalent to: if (a > b) { return c; } else if (a < b) { return d; } else { return e; }
ebool isGreater = FHE.gt(a, b);
ebool isLess = FHE.lt(a, b);

euint32 result = FHE.select(
    isGreater, 
    c, 
    FHE.select(isLess, d, e)
);
```

## 4. Casting Between Types

You can cast between different encrypted integer sizes.

```solidity
euint8 smallVal = ...;
euint32 largeVal = FHE.asEuint32(smallVal); // Upscaling

euint32 anotherVal = ...;
euint16 truncatedVal = FHE.asEuint16(anotherVal); // Downscaling (truncates)
```

## 5. Efficiency Considerations
- **Bitwise vs. Arithmetic**: Bitwise operations are generally faster than arithmetic ones in FHE.
- **Power of Two**: Divisions and multiplications by powers of two should use shifts (`shl`, `shr`) for significantly better performance.
- **Table Lookups**: For complex functions, consider using table lookups (if supported by the specific FHEVM version) or approximating with polynomials.

## 6. Self-Contained References
Check the `references/` folder for:
- `AdvancedOps.sol`: Example contract demonstrating all advanced operations.
- `MathUtils.sol`: Helper library for common FHE math patterns.
