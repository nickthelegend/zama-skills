---
name: Zama FHEVM Architecture Deep Dive
description: Premium architectural guide to the inner workings of FHEVM. Understand the role of the Gateway, KMS, MPC nodes, and the FHE computation graph.
category: blockchain
tags: [fhevm, architecture, kms, gateway, protocol]
---

# Zama FHEVM Architecture Deep Dive

Understanding the architecture of FHEVM is essential for debugging and optimizing complex applications.

## 1. The Big Picture

FHEVM is not just a modified EVM; it's a multi-layered system that coordinates encrypted computations across different nodes.

### Layer 1: The Blockchain (EVM)
The blockchain stores the **ciphertext handles** (references to the actual encrypted data). Standard EVM operations (like routing and storage) happen here.

### Layer 2: The Zama Gateway
When a contract performs an FHE operation (e.g., `FHE.add`), it emits an event. The Gateway listens to these events and builds a **computation graph**.

### Layer 3: The Key Management Service (KMS)
The KMS is a decentralized network of nodes that hold shares of a global private key. They use Multi-Party Computation (MPC) to execute the computation graph provided by the Gateway.

## 2. The Lifecycle of a Transaction

1.  **Submission**: User sends a transaction with an `externalEuint` and a ZK proof.
2.  **Validation**: The contract validates the proof and stores the handle.
3.  **Operation**: The contract calls an `FHE` function, emitting an event.
4.  **Gateway Pickup**: The Gateway notices the event and prepares the task for the KMS.
5.  **KMS Execution**: KMS nodes jointly compute the result.
6.  **Update**: The new handle (result) is posted back to the blockchain.

## 3. Threshold Decryption

Decryption only happens when a quorum of KMS nodes agrees. This is triggered by a `FHE.requestDecryption` call in the contract, which the Gateway verifies against the **Access Control List (ACL)**.

## 4. Why This Matters
- **Latency**: Understanding the Gateway/KMS loop explains why FHE operations take longer than standard ones.
- **Security**: The data is never decrypted by any single node; it's always encrypted or "shared" between MPC nodes.

## 5. Self-Contained References
Check the `references/` folder for:
- `KMSArchitecture.md`: Detailed breakdown of the KMS protocol.
- `GatewayFlow.png`: Diagram of the Gateway interaction (see docs).
- `fhevm-whitepaper.pdf`: The core technical paper.
