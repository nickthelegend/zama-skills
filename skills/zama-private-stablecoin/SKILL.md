---
name: Zama Private Stablecoin
description: Premium guide to building a privacy-preserving stablecoin on FHEVM. Learn to manage encrypted reserves, collateralization ratios, and private transfers.
category: blockchain
tags: [fhevm, solidity, stablecoin, finance, privacy]
---

# Zama Private Stablecoin

A private stablecoin allows users to hold and transfer value pegged to a currency (like USD) without their balances or transaction history being public.

## 1. Architecture

The stablecoin is built on top of the `ERC7984` standard, adding logic for minting based on encrypted collateral.

### State Variables
```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract PrivateStablecoin is ERC7984, ZamaEthereumConfig {
    // Encrypted amount of collateral (e.g., ETH) held for each user
    mapping(address => euint32) private collateral;
}
```

## 2. Minting with Private Collateral

Users can mint stablecoins by locking encrypted collateral. The contract verifies the collateralization ratio using FHE.

```solidity
function mint(externalEuint32 amountToMint, externalEuint32 collateralProvided, bytes calldata proof) public {
    euint32 mintVal = FHE.fromExternal(amountToMint, proof);
    euint32 collateralVal = FHE.fromExternal(collateralProvided, proof);
    
    // Check if (collateralVal * price) / mintVal > 1.5
    // All math remains encrypted
    // ...
}
```

## 3. Privacy vs. Compliance
- **User Privacy**: Balances and transfers are hidden from the public.
- **Auditable Reserves**: The contract can provide a cryptographic proof that its total reserves cover the total supply without revealing individual account details.

## 4. Self-Contained References
Check the `references/` folder for:
- `PrivateUSD.sol`: Example stablecoin implementation.
- `ReservesAudit.ts`: Script for verifying contract solvency privately.
