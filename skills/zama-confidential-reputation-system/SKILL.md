---
name: Zama Confidential Reputation System
description: Premium guide to building private reputation and credit scoring systems on FHEVM. Learn to aggregate user ratings and financial history into an encrypted score.
category: Security
difficulty: advanced
tags: [fhevm, solidity, reputation, credit-score, identity, privacy]
estimated_time: 4 hours
---

# Zama Confidential Reputation System

In a decentralized world, reputation is everything. However, making reputation public exposes a user's entire history (who they've worked with, their financial reliability, etc.). A Confidential Reputation System on FHEVM allows users to build trust without sacrificing their privacy.

## 1. Overview
In a Confidential Reputation System:
- **Ratings**: Individual ratings (from 1 to 5 stars) are submitted as encrypted values.
- **Aggregation**: The system computes a weighted average or sum of ratings homomorphically.
- **Proof of Reputation**: Users can generate a proof (using ZKP or a selective decryption) that their reputation is above a certain threshold (e.g., "I have at least a 4.5 rating") without revealing the exact score.

## 2. Prerequisites
- Mastery of `zama-solidity-encrypted-types`.
- Familiarity with `zama-private-identity-verification`.

## 3. Step-by-Step Implementation

### Step 1: Submitting an Encrypted Rating
Validators or peers submit ratings as `euint8`.

```solidity
function submitRating(address subject, externalEuint8 rating, bytes calldata proof) public {
    euint8 r = FHE.fromExternal(rating, proof);
    
    // Add to subject's aggregate score
    userReputation[subject].totalScore = FHE.add(userReputation[subject].totalScore, r);
    userReputation[subject].count++;
    
    FHE.allowThis(userReputation[subject].totalScore);
}
```

### Step 2: Calculating the Average
The average is calculated as an encrypted value.

```solidity
function getAverageScore(address subject) public view returns (euint8) {
    Reputation storage rep = userReputation[subject];
    return FHE.div(rep.totalScore, FHE.asEuint8(uint8(rep.count)));
}
```

### Step 3: Threshold Verification
A protocol (e.g., a lending platform) can check if a user is "Trustworthy" based on an encrypted threshold.

```solidity
function isTrustworthy(address user) public view returns (ebool) {
    euint8 avg = getAverageScore(user);
    return FHE.ge(avg, FHE.asEuint8(4)); // Minimum 4-star rating
}
```

## 4. Financial Credit Scores
By integrating with DeFi protocols, you can include encrypted debt-to-income ratios or repayment histories into the score, enabling "Private Undercollateralized Lending".

## 5. Security Considerations
- **Rating Sybils**: Ensure only authorized entities (or users with specific credentials) can submit ratings.
- **Data Aging**: Implement logic to "decay" old ratings, ensuring the reputation stays current. This can be done by periodically multiplying the total score by an encrypted factor < 1.

## 6. Gas Optimization Tips
- **Batch Updates**: Instead of updating the score on every rating, collect ratings in a buffer and perform a batch update to save gas on `FHE.allow` calls.

## 7. Common Pitfalls & Solutions
- **Division by Zero**: If `count` is zero, the `FHE.div` will fail or wrap. Always ensure `count > 0` before calculating an average.

## 8. Self-Contained References
Check the `references/` folder for:
- `ReputationEngine.sol`: Core scoring logic.
- `CreditScoreExtension.sol`: Financial history integration.
- `RepTest.ts`: Script to simulate rating aggregation and threshold checks.
