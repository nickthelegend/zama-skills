---
name: Zama FHEVM Performance Benchmarking
description: Premium guide to measuring and analyzing the performance of FHE operations on-chain. Learn about operation latency, Gateway turnaround times, and gas-to-time ratios.
category: blockchain
tags: [fhevm, performance, benchmarking, latency, metrics]
---

# Zama FHEVM Performance Benchmarking

Performance in FHEVM is measured differently than in standard EVM. You must account for the asynchronous computation cycle.

## 1. Key Metrics

- **EVM Execution Time**: Time taken for the host chain to process the transaction and emit events.
- **Gateway Pickup Latency**: Time between the event emission and the Gateway building the task.
- **KMS Computation Time**: Actual time taken for the MPC nodes to compute the FHE operation.
- **Decryption Round-Trip**: The most critical metric—total time from `FHE.requestDecryption` to the callback being executed.

## 2. Benchmarking Tooling

Use a custom Hardhat task to measure the time difference between blocks.

```typescript
// Example Hardhat Task snippet
task("benchmark-add", "Measures FHE.add performance")
  .setAction(async (taskArgs, hre) => {
    const start = Date.now();
    const tx = await contract.performEncryptedAdd(a, b);
    await tx.wait();
    const end = Date.now();
    console.log(`FHE.add (EVM part): ${end - start}ms`);
  });
```

## 3. Real-world Latency
On Sepolia, a decryption request usually takes **2-4 blocks** (approx. 30-60 seconds) to complete. Operations that don't require decryption are processed faster by the coprocessors but still have a fixed overhead.

## 4. Optimization Strategies
- **Parallelization**: Don't wait for one decryption before starting another if they are independent.
- **Off-chain Anticipation**: Use the Relayer SDK to estimate results off-chain for UI responsiveness while waiting for on-chain finality.

## 5. Self-Contained References
Check the `references/` folder for:
- `BenchmarkTask.ts`: Ready-to-run Hardhat benchmarking script.
- `PerformanceReport.md`: Sample metrics from the Zama devnet.
