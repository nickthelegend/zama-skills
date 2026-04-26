---
name: Zama Encrypted Wordle Game
description: Premium guide to building an encrypted Wordle-style game on-chain using FHEVM. Learn to handle secret words, validate guesses, and provide feedback without leaking the solution.
category: blockchain
tags: [fhevm, solidity, wordle, gaming, privacy]
---

# Zama Encrypted Wordle Game

This skill demonstrates how to use FHEVM to build games where the "house" or the game state needs to remain secret from the players.

## 1. Game Mechanics in FHE

In a traditional Wordle game, the secret word is usually hidden in the frontend or revealed after each guess. In FHE Wordle, the secret word is stored as an encrypted value in the smart contract.

## 2. Core Implementation (`FHEWordle.sol`)

The contract stores the secret word as a series of encrypted characters (or a single packed value).

### State Variables
```solidity
import { FHE, euint8, ebool } from "@fhevm/solidity/lib/FHE.sol";

contract FHEWordle is ZamaEthereumConfig {
    // The secret word (5 letters) stored as encrypted characters
    euint8[5] private secretWord;
    
    // Track player attempts and status
    mapping(address => uint256) public attempts;
}
```

### Validating a Guess
When a player submits a guess, the contract compares it to the `secretWord` character by character using `FHE.eq` and `FHE.select`.

```solidity
function submitGuess(uint8[5] calldata guess) public {
    // Feedback: 0 = Gray, 1 = Yellow, 2 = Green
    euint8[5] memory feedback;
    
    for (uint i = 0; i < 5; i++) {
        euint8 secretChar = secretWord[i];
        uint8 guessChar = guess[i];
        
        // Green: Correct letter, correct position
        ebool isGreen = FHE.eq(secretChar, guessChar);
        
        // Simplified Yellow/Gray logic using FHE.select
        // In a real implementation, you'd iterate to check for Yellow (correct letter, wrong position)
        feedback[i] = FHE.select(isGreen, FHE.asEuint8(2), FHE.asEuint8(0));
    }
    
    // Allow the player to see the feedback (encrypted)
    for (uint i = 0; i < 5; i++) {
        FHE.allow(feedback[i], msg.sender);
    }
}
```

## 3. Decrypting the Feedback

The player uses the Relayer SDK to decrypt the feedback after the transaction is processed.

```typescript
const feedbackHandles = await contract.getFeedback(userAddress);
const clearFeedback = await Promise.all(
    feedbackHandles.map(handle => 
        fhevm.userDecryptEuint(FhevmType.euint8, handle, contractAddress, userSigner)
    )
);

// clearFeedback might look like [2, 0, 1, 0, 2]
```

## 4. Key Advantages
- **Uncheatable**: No one, not even the contract owner or validators, can see the secret word or the player's progress until revealed.
- **Fairness**: Every player interacts with the same encrypted state without being able to see others' guesses.

## 5. Performance Tips
- **Packing**: Consider packing 5 characters into a single `euint32` or `euint64` to reduce the number of FHE operations.
- **Asynchronous Flow**: Remind users that feedback is not available in the same block as the guess.

## 6. Self-Contained References
Check the `references/` folder for:
- `FHEWordle.sol`: Example implementation of the game logic.
- `WordleLogic.ts`: Frontend logic for processing guesses.
