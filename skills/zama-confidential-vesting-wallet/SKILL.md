---
name: Zama Confidential Vesting Wallet
description: Premium guide to building a private token vesting wallet on FHEVM. Learn to manage encrypted release schedules and hide the amount of tokens being vested.
category: finance
tags: [fhevm, solidity, vesting, finance, privacy]
---

# Zama Confidential Vesting Wallet

A confidential vesting wallet allows for token distributions where the specific amounts being released or the total vested amount can be hidden from the public.

## 1. Core Implementation

The contract uses `ConfidentialERC20` for the tokens and stores the vesting parameters (start, duration) in cleartext, while the amounts can be encrypted.

### State Variables
```solidity
import { FHE, euint64 } from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialVestingWallet is ZamaEthereumConfig {
    address public beneficiary;
    uint64 public start;
    uint64 public duration;
    
    euint64 private _released;
}
```

## 2. Vesting Logic

The amount available for release is calculated based on the elapsed time, but the resulting `euint64` is never decrypted on-chain.

```solidity
function vestedAmount(uint64 timestamp) public view returns (euint64) {
    euint64 totalAllocation = IConfidentialERC20(token).confidentialBalanceOf(address(this));
    
    if (timestamp < start) {
        return FHE.asEuint64(0);
    } else if (timestamp >= start + duration) {
        return totalAllocation;
    } else {
        // Linear vesting: (totalAllocation * (timestamp - start)) / duration
        euint64 timeElapsed = FHE.asEuint64(timestamp - start);
        return FHE.div(FHE.mul(totalAllocation, timeElapsed), FHE.asEuint64(duration));
    }
}
```

## 3. Releasing Tokens

When the beneficiary calls `release()`, the contract calculates the delta and performs a confidential transfer.

```solidity
function release() public {
    euint64 releasable = FHE.sub(vestedAmount(uint64(block.timestamp)), _released);
    _released = FHE.add(_released, releasable);
    
    IConfidentialERC20(token).confidentialTransfer(beneficiary, releasable);
}
```

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialVestingWallet.sol`: Full implementation.
- `TestConfidentialVestingWallet.sol`: Test contract.
