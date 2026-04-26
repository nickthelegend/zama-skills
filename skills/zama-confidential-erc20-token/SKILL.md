---
name: Zama Confidential ERC20 Token (ERC7984)
description: Detailed guide to implementing and deploying a confidential ERC20 token using the ERC7984 standard on FHEVM
category: blockchain
tags: [fhevm, solidity, erc20, erc7984, openzeppelin]
---

# Zama Confidential ERC20 Token (ERC7984)

ERC7984 is a standard for confidential tokens on FHEVM, extending the familiar ERC20 interface with encrypted balances and transfers.

## 1. Prerequisites

You will need the OpenZeppelin confidential contracts library:

```bash
npm install @openzeppelin/confidential-contracts
```

## 2. Basic Implementation

To create a confidential token, inherit from `ERC7984` and `ZamaEthereumConfig`.

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {FHE, externalEuint64, euint64} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {ERC7984} from "@openzeppelin/confidential-contracts/token/ERC7984.sol";

contract MyConfidentialToken is ZamaEthereumConfig, ERC7984, Ownable2Step {
    constructor(
        address owner,
        uint64 initialSupply,
        string memory name,
        string memory symbol,
        string memory tokenURI
    ) ERC7984(name, symbol, tokenURI) Ownable(owner) {
        // Minting initial supply as encrypted value
        euint64 encryptedAmount = FHE.asEuint64(initialSupply);
        _mint(owner, encryptedAmount);
    }
}
```

## 3. Key Functions

- **`confidentialBalanceOf(address account)`**: Returns the `euint64` handle representing the account's balance.
- **`confidentialTransfer(address to, bytes32 encryptedAmount, bytes calldata proof)`**: Performs an encrypted transfer.
- **`confidentialApprove(address spender, bytes32 encryptedAmount, bytes calldata proof)`**: Confidential approval for spending.

## 4. Frontend Integration

When interacting with the token from a frontend, use the Relayer SDK to create encrypted inputs for transfers:

```typescript
const encryptedInput = await fhevm
  .createEncryptedInput(tokenAddress, userAddress)
  .add64(100) // Transfer 100 tokens
  .encrypt();

await token.confidentialTransfer(
  recipientAddress,
  encryptedInput.handles[0],
  encryptedInput.inputProof
);
```

## 5. The "Silent Failure" Pattern

A critical security feature of ERC7984 is that transfers do not revert if the user has an insufficient balance. Instead, the transaction succeeds but transfers `0` tokens. This prevents attackers from "probing" a user's balance by observing which transactions revert.

### Handling it in the Frontend
Your frontend should check the balance **before** sending a transaction to provide a better user experience, while the contract ensures privacy on-chain.

## 6. Security & Auditing Tips
- **Total Supply**: While individual balances are encrypted, the `totalSupply` is often public. Be careful not to leak info if you implement a "minting" mechanism that is triggered by private events.
- **ACL Permissions**: Ensure `FHE.allow` is called after every `_mint` or `_transfer` so the recipient can actually see their new balance handle.

## 7. Self-Contained References
Check the `references/` folder for:
- `ConfidentialERC20.sol`: Implementation of the ERC7984 standard.
- `IConfidentialERC20.md`: Interface documentation.
- `erc7984-tutorial.md`: Step-by-step guide from Zama docs.
