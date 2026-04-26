---
name: Zama Batch FHE Operations
description: Premium guide to performing bulk computations on encrypted data. Learn to use arrays of euints and optimize Gateway calls for high-throughput apps.
category: blockchain
tags: [fhevm, batching, efficiency, solidity]
---

# Zama Batch FHE Operations

Batching is the best way to handle multiple encrypted values in a single transaction, reducing the overhead of Gateway/KMS interaction.

## 1. Using Encrypted Arrays

You can store and manipulate arrays of `euint` types.

```solidity
euint32[10] private _batchData;

function processBatch(externalEuint32[10] calldata inputs, bytes[] calldata proofs) public {
    for (uint i = 0; i < 10; i++) {
        euint32 val = FHE.fromExternal(inputs[i], proofs[i]);
        _batchData[i] = FHE.add(_batchData[i], val);
        FHE.allowThis(_batchData[i]);
    }
}
```

## 2. Aggregation Logic
If you need to sum an entire array, do it in a single loop to minimize state updates.

```solidity
function sumBatch() public view returns (euint32) {
    euint32 total = FHE.asEuint32(0);
    for (uint i = 0; i < 10; i++) {
        total = FHE.add(total, _batchData[i]);
    }
    return total;
}
```

## 3. Gas and Latency
While batching saves on transaction overhead, remember that the KMS still executes each FHE operation. A batch of 100 additions will take longer to decrypt than a single one.

## 4. Self-Contained References
Check the `references/` folder for:
- `BatchProcessor.sol`: Example of bulk FHE processing.
- `BatchTest.ts`: Performance benchmarking for batch operations.
