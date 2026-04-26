---
name: Zama Private Cross-Chain Messaging
description: Premium guide to sending encrypted messages and assets between chains using Zama FHEVM and the LayerZero OApp protocol.
category: blockchain
tags: [fhevm, layerzero, cross-chain, messaging, privacy]
---

# Zama Private Cross-Chain Messaging

Combining FHE with cross-chain protocols like LayerZero allows for private state synchronization across different networks.

## 1. The OApp Pattern

Zama's `protocol-apps` repository demonstrates how to build "Omnichain Applications" (OApps) that handle encrypted data.

```solidity
import { OApp, MessagingReceipt, MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

contract PrivateMessenger is OApp, ZamaEthereumConfig {
    // Send an encrypted value to another chain
    function sendEncrypted(uint32 dstEid, externalEuint32 val, bytes calldata proof) public payable {
        euint32 secretVal = FHE.fromExternal(val, proof);
        bytes memory payload = abi.encode(secretVal);
        _lzSend(dstEid, payload, options, MessagingFee(msg.value, 0), msg.sender);
    }
}
```

## 2. Privacy Preservation
The payload sent across the wire (via LayerZero) contains the ciphertext. Even relayers and oracles cannot see the underlying data, ensuring privacy remains intact during transit.

## 3. Self-Contained References
Check the `references/` folder for:
- `GovernanceOApp.sol`: Example of a cross-chain OApp using FHE.
- `CrossChainTest.ts`: Testing suite for cross-chain encrypted messaging.
