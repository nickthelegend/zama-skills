---
name: Zama FHEVM Mocks Testing
description: Premium guide to testing confidential contracts locally using Zama's mock environment. Self-contained with test examples and configuration tips.
category: blockchain
tags: [fhevm, testing, hardhat, mock, security]
---

# Zama FHEVM Mocks Testing

Testing FHEVM contracts on a live network is slow and expensive. Zama provides a mock environment that simulates FHE operations locally, allowing for rapid development and testing.

## 1. Enabling the Mock Environment

In your `hardhat.config.ts`, you can toggle between the mock and live environment.

```typescript
import "@fhevm/hardhat-plugin";

const config = {
  // ...
  fhevm: {
    isMock: true, // Set to true for local testing
  }
};
```

## 2. Writing Mock Tests

Mock tests look almost identical to live tests, but they run instantly on the local Hardhat network.

```typescript
import { expect } from "chai";
import { ethers, fhevm } from "hardhat";

describe("FHECounter Mock", function () {
  it("should increment in mock environment", async function () {
    const factory = await ethers.getContractFactory("FHECounter");
    const contract = await factory.deploy();
    const [alice] = await ethers.getSigners();

    // In mock mode, encryption and decryption are simulated
    const input = await fhevm.createEncryptedInput(contract.address, alice.address)
      .add32(1)
      .encrypt();

    await contract.increment(input.handles[0], input.inputProof);

    const encryptedCount = await contract.getCount();
    
    // Decryption is instant in mock mode
    const clearCount = await fhevm.userDecryptEuint(
      FhevmType.euint32,
      encryptedCount,
      contract.address,
      alice
    );

    expect(clearCount).to.equal(1);
  });
});
```

## 3. Differences Between Mock and Live

| Feature | Mock | Live (Sepolia) |
| --- | --- | --- |
| Execution Speed | Very Fast | Slow (15-30s per tx) |
| Decryption | Instant | Requires Gateway/KMS (several blocks) |
| Gas Costs | Simulated | Real (Higher than standard) |
| Accuracy | 99% | 100% |

## 4. Best Practices for Mock Testing

1.  **Test Edge Cases**: Use the mock environment to test boundary conditions (e.g., overflows) which are faster to iterate on.
2.  **State Verification**: Use `fhevm.userDecryptEuint` frequently in your tests to ensure the contract state is evolving as expected.
3.  **Transition to Live**: Always run your final test suite on Sepolia before deploying to production.

## 5. Self-Contained References
Check the `references/` folder for:
- `FHETest.ts`: Comprehensive example of FHEVM testing.
- `FhevmMockProvider.ts`: Implementation details of the mock provider.
- `MockFhevmInstance.ts`: Core logic of the simulated FHEVM.
