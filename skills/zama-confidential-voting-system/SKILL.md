---
name: Zama Confidential Voting System
description: Premium guide to building a private voting system on FHEVM. Learn to collect encrypted votes, aggregate them securely, and reveal the results without compromising voter privacy.
category: blockchain
tags: [fhevm, solidity, voting, governance, privacy]
---

# Zama Confidential Voting System

Building a fair and private voting system is one of the most powerful use cases for FHE. In this system, each voter submits an encrypted vote, and the contract calculates the total while keeping individual choices secret.

## 1. Core Logic

Voters submit an `externalEuint8` representing their choice (e.g., 0 for No, 1 for Yes).

### State Variables
```solidity
import { FHE, euint32, ebool } from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialVoting is ZamaEthereumConfig {
    // Total votes for each option (encrypted)
    euint32 private yesVotes;
    euint32 private noVotes;
    
    // Track who has voted
    mapping(address => bool) public hasVoted;
}
```

### Casting a Vote
```solidity
function castVote(externalEuint8 encryptedChoice, bytes calldata proof) public {
    require(!hasVoted[msg.sender], "Already voted");
    
    euint8 choice = FHE.fromExternal(encryptedChoice, proof);
    
    // Increment yesVotes if choice is 1, noVotes if choice is 0
    // Using FHE.select to handle the branchless update
    ebool isYes = FHE.eq(choice, 1);
    ebool isNo = FHE.eq(choice, 0);
    
    yesVotes = FHE.add(yesVotes, FHE.select(isYes, FHE.asEuint32(1), FHE.asEuint32(0)));
    noVotes = FHE.add(noVotes, FHE.select(isNo, FHE.asEuint32(1), FHE.asEuint32(0)));
    
    FHE.allowThis(yesVotes);
    FHE.allowThis(noVotes);
    
    hasVoted[msg.sender] = true;
}
```

## 2. Revealing Results

Once the voting period ends, the totals can be decrypted via the Zama Gateway.

```solidity
function getResults() public onlyAfterEnd {
    bytes32[] memory cts = new bytes32[](2);
    cts[0] = FHE.toBytes32(yesVotes);
    cts[1] = FHE.toBytes32(noVotes);
    FHE.requestDecryption(cts, this.revealCallback.selector);
}

function revealCallback(uint256 requestId, bytes memory cleartexts, bytes memory proof) public {
    FHE.checkSignatures(requestId, cleartexts, proof);
    (uint32 yes, uint32 no) = abi.decode(cleartexts, (uint32, uint32));
    finalYesVotes = yes;
    finalNoVotes = no;
}
```

## 3. Security Considerations
- **Voter Privacy**: Individual votes are never decrypted. Only the aggregate is revealed.
- **Fairness**: No one can see the partial results while the vote is ongoing, preventing bandwagon effects.
- **Replays**: Ensure the `inputProof` is validated to prevent re-using old vote ciphertexts.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialVoting.sol`: Complete contract source.
- `VotingTest.ts`: Test suite for encrypted voting.
