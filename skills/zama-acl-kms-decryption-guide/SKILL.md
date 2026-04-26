---
name: Zama ACL and KMS Decryption Guide
description: In-depth guide to access control lists (ACL) and the Key Management Service (KMS) workflow for secure decryption in FHEVM
category: blockchain
tags: [fhevm, acl, kms, decryption, security]
---

# Zama ACL and KMS Decryption Guide

Understanding how FHEVM manages permissions and decryption is critical for building secure confidential applications.

## 1. Access Control List (ACL)

The ACL determines who has permission to decrypt or perform operations on a specific encrypted value (ciphertext handle).

### Granting Permissions in Solidity

Use the `FHE.allow` and `FHE.allowThis` functions to manage access.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract MyContract {
    euint32 private _secret;

    function doSomething(euint32 value) public {
        _secret = value;

        // Grant permission to this contract to use the value in future computations
        FHE.allowThis(_secret);

        // Grant permission to the caller to decrypt this value
        FHE.allow(_secret, msg.sender);
        
        // Grant permission to another specific address
        FHE.allow(_secret, 0x123...);
    }
}
```

## 2. Types of Decryption

### User Decryption
The value is decrypted and returned privately to the authorized user. The user's wallet is used to sign a request, and the Relayer SDK handles the communication with the KMS.

### Public Decryption
The value is decrypted and becomes publicly visible. This is often used for game results, auction winners, or any data that should be revealed after a certain condition is met.

## 3. The KMS Workflow

The Key Management Service (KMS) is a decentralized network of nodes that perform threshold decryption via Multi-Party Computation (MPC).

1.  **Request**: A user or contract requests a decryption.
2.  **Gateway**: The Zama Gateway verifies the ACL permissions on-chain.
3.  **KMS Nodes**: If authorized, KMS nodes jointly decrypt the value without any single node ever seeing the full private key.
4.  **Result**: The decrypted value is returned to the user (User Decryption) or posted on-chain (Public Decryption).

## 4. Frontend Decryption Example

Using the Relayer SDK to decrypt a value authorized for the user:

```typescript
const clearValue = await fhevm.userDecryptEuint(
  FhevmType.euint32,
  encryptedHandle,
  contractAddress,
  userSigner
);
```

## 5. Security Architecture

- **Threshold Decryption**: A quorum of KMS nodes (e.g., 9 out of 13) must agree to decrypt a value.
- **Secure Enclaves**: KMS nodes run inside AWS Nitro Enclaves to prevent node operators from accessing key shares.
- **Auditable**: All decryption requests and results are logged and can be verified cryptographically.
