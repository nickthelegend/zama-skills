---
name: Zama Confidential ERC20 Token (ERC7984)
description: The definitive guide to building and deploying confidential ERC20 tokens using the Zama FHEVM. Learn about the ERC7984 standard, private transfers, and encrypted allowances.
category: Standards
difficulty: intermediate
tags: [fhevm, solidity, erc20, erc7984, token]
estimated_time: 2.5 hours
---

# Zama Confidential ERC20 Token (ERC7984)

Standard ERC20 tokens expose every transaction and balance to the world. The ERC7984 standard, powered by Zama's FHEVM, brings full confidentiality to Ethereum tokens.

## 1. Overview
In a Confidential ERC20:
- **Balances** are stored as `euint32` or `euint64`.
- **Transfer Amounts** are encrypted.
- **Allowances** can be encrypted or public depending on the use case.

## 2. Prerequisites
- Basic understanding of the ERC20 standard.
- Completed the `zama-solidity-encrypted-types` skill.

## 3. Step-by-Step Implementation

### Step 1: State Variables
Instead of `mapping(address => uint256)`, we use `euint`.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialERC20 is ZamaEthereumConfig {
    mapping(address => euint32) private _balances;
    euint32 private _totalSupply;
}
```

### Step 2: The Transfer Logic
Transfers in FHEVM require branchless logic.

```solidity
function _transfer(address from, address to, euint32 amount) internal {
    euint32 fromBalance = _balances[from];
    
    // Check if sender has enough balance (branchless)
    ebool canTransfer = FHE.le(amount, fromBalance);
    
    // Calculate new balances using FHE.select or subtraction logic
    euint32 amountToTransfer = FHE.select(canTransfer, amount, FHE.asEuint32(0));
    
    _balances[from] = FHE.sub(fromBalance, amountToTransfer);
    _balances[to] = FHE.add(_balances[to], amountToTransfer);
    
    FHE.allowThis(_balances[from]);
    FHE.allowThis(_balances[to]);
}
```

### Step 3: Approval and Allowance
Encrypted allowances prevent observers from knowing the spending limits of a contract.

```solidity
function approve(address spender, externalEuint32 amount, bytes calldata proof) public {
    euint32 val = FHE.fromExternal(amount, proof);
    _allowances[msg.sender][spender] = val;
    FHE.allowThis(val);
}
```

## 4. Security Considerations
- **Total Supply Leaks**: Even if balances are private, the `totalSupply()` is often public. Be aware of what this reveals about the token's ecosystem.
- **Zero-Value Transfers**: An attacker might try to send zero-value transfers to observe gas patterns. FHEVM operations have fixed gas costs to mitigate this.

## 5. Gas Optimization Tips
- **Bit-Width Choice**: Use `euint32` for tokens with low decimals or small supplies. Use `euint64` for high-precision assets.
- **Batching**: Use `FHE.allow()` on arrays to save gas during multi-transfers.

## 6. Common Pitfalls & Solutions
- **Event Logging**: Do NOT log the `amount` in a transfer event. Standard ERC20 events must be modified to exclude the encrypted value.
- **Viewing Balances**: Users cannot see their balance via a simple `balanceOf()` call. They must use the Relayer SDK decryption flow.

## 7. Full Implementation Reference
The `references/` folder contains a complete implementation of `ConfidentialERC20.sol` which includes:
- Minting and Burning logic.
- Full ERC7984 compliance.
- Integration with the Zama ACL.

## 8. Self-Contained References
Check the `references/` folder for:
- `ConfidentialERC20.sol`: The core contract implementation.
- `IConfidentialERC20.sol`: Interface for integration.
- `erc7984-tutorial.md`: Detailed breakdown of the standard.
