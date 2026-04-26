---
name: Zama Confidential Wrapped ETH (CWETH)
description: Premium guide to implementing a confidential version of WETH on FHEVM. Learn to wrap public ETH into encrypted tokens and unwrap them privately.
category: finance
tags: [fhevm, solidity, weth, cweth, privacy]
---

# Zama Confidential Wrapped ETH (CWETH)

CWETH allows users to turn their public ETH into an encrypted ERC20-like token that can be used in private DeFi protocols.

## 1. Deposit (Wrapping)

When a user sends ETH to the contract, they receive an equivalent amount of encrypted tokens.

```solidity
function deposit(externalEuint64 encryptedAmount, bytes calldata proof) public payable {
    euint64 amount = FHE.fromExternal(encryptedAmount, proof);
    // Verify that the encrypted amount matches the msg.value
    // Note: This usually requires a decryption or a specific FHE check
    FHE.req(FHE.eq(amount, FHE.asEuint64(uint64(msg.value))));
    
    _mint(msg.sender, amount);
}
```

## 2. Withdrawal (Unwrapping)

Unwrapping requires the user to submit an encrypted amount to burn, which then triggers a public ETH transfer.

```solidity
function withdraw(externalEuint64 encryptedAmount, bytes calldata proof) public {
    euint64 amount = FHE.fromExternal(encryptedAmount, proof);
    _burn(msg.sender, amount);
    
    // Request decryption of the amount to know how much ETH to send
    FHE.requestDecryption([FHE.toBytes32(amount)], this.withdrawCallback.selector);
}

function withdrawCallback(uint256 requestId, uint64 clearAmount) public {
    // ... validation and ETH transfer ...
}
```

## 3. Security Considerations
- **Balance Leaks**: Be careful with `deposit` logic to ensure the `msg.value` doesn't leak the encrypted amount if it's supposed to be secret (though `msg.value` is public).
- **Relayer Fees**: Decryption requests in `withdraw` require gas and potentially relayer fees.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialWETH.sol`: Core contract.
- `TestConfidentialWETH.sol`: Test contract.
