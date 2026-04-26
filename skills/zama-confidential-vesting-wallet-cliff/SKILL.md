---
name: Zama Confidential Vesting Wallet with Cliff
description: Premium guide to building a private token vesting wallet with a cliff period on FHEVM. Ensure no tokens are released until a specific milestone is reached, all while keeping balances private.
category: finance
tags: [fhevm, solidity, vesting, cliff, privacy]
---

# Zama Confidential Vesting Wallet with Cliff

This advanced vesting contract adds a "cliff" period. Before the cliff is reached, the releasable amount is always encrypted zero.

## 1. Implementing the Cliff

The cliff is a cleartext timestamp. If the current time is less than the cliff, the function returns an encrypted zero.

```solidity
function vestedAmount(uint64 timestamp) public view returns (euint64) {
    if (timestamp < cliff) {
        return FHE.asEuint64(0);
    }
    // ... rest of the vesting logic ...
}
```

## 2. Payout Patterns
The contract inherits from `ConfidentialVestingWallet` and overrides the `vestedAmount` function to include the cliff check.

## 3. Advantages of Private Vesting
- **Anti-Market Manipulation**: Prevents outsiders from knowing exactly how many tokens a team member or investor is receiving, reducing sell pressure front-running.
- **Privacy for Employees**: Keeps compensation details confidential on a public ledger.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialVestingWalletCliff.sol`: Implementation with cliff logic.
- `TestConfidentialVestingWalletCliff.sol`: Test contract.
