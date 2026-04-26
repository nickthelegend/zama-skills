---
name: Zama FHEVM Coprocessor Integration
description: Senior-level guide to understanding and leveraging the FHEVM Coprocessor network. Learn about symbolic execution, off-chain computation, and the future of hardware acceleration.
category: Foundation
difficulty: advanced
tags: [fhevm, coprocessor, architecture, symbolic-execution, scaling]
estimated_time: 6 hours
---

# Zama FHEVM Coprocessor Integration

The Zama FHEVM is not a traditional blockchain; it's a hybrid architecture where the main chain handles the control flow and state pointers, while a specialized Coprocessor network performs the actual homomorphic computations. This guide dives deep into this architecture.

## 1. Overview: Symbolic Execution
In Zama's v2 architecture, the EVM does not execute FHE operations directly. When you call `FHE.add(a, b)`, the EVM:
1.  **Validates** the handles `a` and `b`.
2.  **Emits** an event for the Coprocessor.
3.  **Returns** a new handle `c` (a pointer) to the caller.

This process is known as **Symbolic Execution**. The actual addition happens off-chain in the Coprocessor network.

## 2. The Coprocessor Lifecycle

### Step 1: Request
A smart contract calls an FHE library function. The `FHEVMExecutor` contract catches this and emits a request.

### Step 2: Computation
A set of Coprocessors (running `TFHE-rs`) pick up the event, fetch the ciphertexts corresponding to the handles, and perform the computation.

### Step 3: Commitment
The Coprocessors commit the result (the new ciphertext) back to the Gateway/KMS.

## 3. Integration Patterns

### Pattern 1: Async Decryption
Decryption is the only time the main chain must "wait" for the Coprocessor.

```solidity
function revealSecret(euint32 val) public {
    // This triggers the coprocessor -> gateway -> KMS loop
    FHE.requestDecryption([val], this.revealCallback.selector);
}
```

### Pattern 2: Performance Scaling
Since FHE operations are symbolic on-chain, you can "chain" hundreds of operations in a single block without exceeding the block gas limit, as long as you don't need the results (decrypted) immediately.

## 4. Hardware Acceleration (HPU)
The Coprocessor network is designed to be hardware-agnostic but optimized for **HPUs (Hardware Processing Units)**. These are specialized ASICs/FPGAs that can compute FHE operations 100x-1000x faster than traditional CPUs.

## 5. Security and Trust
- **Public Verifiability**: Everything the Coprocessors do is publicly verifiable. In the future, Zama will use ZK-FHE to provide cryptographic proof of correct computation.
- **Majority Consensus**: Currently, multiple Coprocessors must agree on a result before it is accepted by the Gateway.

## 6. Common Pitfalls & Solutions
- **Handle Expiration**: Handles are pointers. If the Coprocessor hasn't processed a request yet, the handle might point to an "uninitialized" value.
- **Latency**: Expect a multi-block delay for any logic that requires a decrypted result.

## 7. Self-Contained References
Check the `references/` folder for:
- `CoprocessorSpecs.md`: Technical specifications of the symbolic execution engine.
- `FHEVMWhitepaper.pdf`: The original architecture document.
- `README.md`: How to run a local Coprocessor node for testing.
