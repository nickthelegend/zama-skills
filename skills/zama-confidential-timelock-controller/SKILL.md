---
name: Zama Confidential Timelock Controller
description: Premium guide to building an encrypted timelock controller on FHEVM. Learn to delay sensitive transactions with encrypted parameters, protecting DAO operations from front-running.
category: governance
difficulty: advanced
tags: [fhevm, solidity, governance, timelock, privacy]
estimated_time: 2 hours
---

# Zama Confidential Timelock Controller

A Timelock Controller is a critical component of DAO governance, ensuring that proposed actions (like treasury transfers or contract upgrades) have a mandatory delay before execution. By using FHE, the parameters of these actions can remain encrypted during the delay period.

## 1. Overview
In a standard Timelock, anyone can see the payload of a pending transaction. In a **Confidential Timelock**, the `target`, `data`, and `value` can be encrypted handles, preventing observers from knowing what will happen until the moment of execution.

## 2. Prerequisites
- Familiarity with the `zama-dao-governance` skill.
- Understanding of the `FHE.requestDecryption` flow.

## 3. Step-by-Step Implementation

### Step 1: Define the Encrypted Proposal
The proposal stores encrypted handles for the transaction details.

```solidity
struct ConfidentialProposal {
    euint32 target;
    euint32 value;
    bytes data; // Note: Large data is usually handled via pointers or specific FHE logic
    uint256 timestamp;
    bool executed;
}
```

### Step 2: Queue the Transaction
```solidity
function queueTransaction(externalEuint32 target, externalEuint32 value, bytes calldata data, uint256 eta) public onlyOwner {
    require(eta >= block.timestamp + minDelay, "Delay too short");
    
    euint32 t = FHE.fromExternal(target, proofT);
    euint32 v = FHE.fromExternal(value, proofV);
    
    bytes32 id = keccak256(abi.encode(t, v, data, eta));
    queued[id] = true;
    
    FHE.allowThis(t);
    FHE.allowThis(v);
}
```

### Step 3: Execute after Delay
Upon execution, the contract requests decryption of the parameters to perform the actual call.

```solidity
function executeTransaction(bytes32 id) public {
    // ... check delay ...
    FHE.requestDecryption([t, v], this.executeCallback.selector);
}

function executeCallback(uint256 requestId, uint32 clearTarget, uint32 clearValue) public {
    // ... perform the call ...
    (bool success, ) = address(uint160(clearTarget)).call{value: clearValue}(data);
    require(success, "Execution failed");
}
```

## 4. Security Considerations
- **Callback Integrity**: Ensure only the Gateway can call the `executeCallback`.
- **Information Leaks**: If the `data` contains public function signatures, some info may still leak. Consider encrypting the entire function call if possible.

## 5. Gas Optimization
- **Batching**: Use `FHE.requestDecryption` for multiple parameters in a single round-trip.

## 6. Common Pitfalls
- **Expired ETA**: If the delay is too long, the ciphertext handles might expire (depending on KMS configuration). Always check handle TTL.

## 7. Self-Contained References
Check the `references/` folder for:
- `CompoundTimelock.sol`: Base timelock logic.
- `TimelockTest.ts`: Script to verify delayed execution.
