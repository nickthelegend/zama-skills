---
name: Zama Confidential DeFi Yield Farming
description: Premium guide to building private yield farming protocols on FHEVM. Learn to manage encrypted staking balances, reward calculations, and compounding without leaking user positions.
category: finance
tags: [fhevm, solidity, defi, yield-farming, staking]
---

# Zama Confidential DeFi Yield Farming

Confidential yield farming allows users to stake assets and earn rewards without revealing the size of their stake or their accumulated gains.

## 1. Staking Encrypted Assets

Users stake an `externalEuint32` amount of an ERC7984 token.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialFarm is ZamaEthereumConfig {
    mapping(address => euint32) private stakedBalances;
    euint32 private totalStaked;
    
    function stake(externalEuint32 amount, bytes calldata proof) public {
        euint32 val = FHE.fromExternal(amount, proof);
        stakedBalances[msg.sender] = FHE.add(stakedBalances[msg.sender], val);
        totalStaked = FHE.add(totalStaked, val);
        
        FHE.allowThis(stakedBalances[msg.sender]);
        FHE.allowThis(totalStaked);
    }
}
```

## 2. Reward Calculation

Rewards are calculated based on the share of the pool, but the share is encrypted.

```solidity
function calculateRewards(address user) public view returns (euint32) {
    euint32 userStake = stakedBalances[user];
    // Reward = (userStake * rewardRate) / totalStaked
    return FHE.div(FHE.mul(userStake, rewardRate), totalStaked);
}
```

## 3. Compounding Gains
Users can "re-invest" their rewards into their stake. Since both the rewards and the stake are encrypted, the user's total position remains hidden.

## 4. Security & Privacy
- **Pool Stats**: While individual stakes are secret, the `totalStaked` might be public or encrypted. If it's public, it leaks some information about the pool's overall size.
- **Harvesting**: Harvesting rewards usually requires a confidential transfer to the user's wallet.

## 5. Self-Contained References
Check the `references/` folder for:
- `ConfidentialFarm.sol`: Complete staking and reward logic.
- `FarmTest.ts`: Script to simulate yield accumulation.
