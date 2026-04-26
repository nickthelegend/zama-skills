---
name: Zama FHEVM with OpenZeppelin Upgrades
description: Premium guide to building upgradeable confidential contracts on FHEVM. Learn to use the UUPS pattern while maintaining encrypted state and ACL permissions.
category: blockchain
tags: [fhevm, solidity, openzeppelin, upgrades, uups]
---

# Zama FHEVM with OpenZeppelin Upgrades

Upgrading FHEVM contracts requires careful management of the `euint` storage slots and the Gateway's ACL permissions.

## 1. UUPS vs Transparent Proxy

We recommend the **UUPS (Universal Upgradeable Proxy Standard)** for FHEVM to save gas and maintain a simpler storage layout.

```solidity
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyUpgradeableFHE is Initializable, UUPSUpgradeable, ZamaEthereumConfig {
    euint32 private _secret;

    function initialize() public initializer {
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
```

## 2. Storage Collisions
Never change the order of `euint` state variables in newer versions. This will cause the ciphertext handles to point to incorrect data in the KMS.

## 3. ACL Migration
Permissions granted in `v1` are generally tied to the contract address. Since the proxy address remains the same, permissions should persist across implementation upgrades.

## 4. Self-Contained References
Check the `references/` folder for:
- `UpgradeableFHE.sol`: Template for UUPS confidential contracts.
- `UpgradeTest.ts`: Script to verify state persistence after upgrade.
