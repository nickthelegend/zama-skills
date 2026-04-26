---
name: Zama Private Lottery
description: Premium guide to building a provably fair and private lottery on FHEVM. Learn to handle secret tickets, random number generation, and automated prize distribution.
category: blockchain
tags: [fhevm, solidity, lottery, gambling, privacy]
---

# Zama Private Lottery

Traditional on-chain lotteries are vulnerable to "look-ahead" attacks where validators or bots can see the numbers before they are revealed. A Zama Private Lottery keeps everything encrypted until the drawing.

## 1. Entering the Lottery

Participants submit an encrypted number (e.g., 1-100).

```solidity
import { FHE, euint8 } from "@fhevm/solidity/lib/FHE.sol";

contract PrivateLottery is ZamaEthereumConfig {
    mapping(address => euint8) private tickets;
    address[] public players;
    
    function buyTicket(externalEuint8 encryptedNumber, bytes calldata proof) public payable {
        require(msg.value >= 0.1 ether, "Ticket price not met");
        
        euint8 number = FHE.fromExternal(encryptedNumber, proof);
        tickets[msg.sender] = number;
        players.push(msg.sender);
        
        FHE.allowThis(number);
    }
}
```

## 2. Drawing the Winner

The winning number can be generated using Zama's `FHE.random()` (if available) or by a secret seed provided by the contract owner.

```solidity
function draw() public onlyOwner {
    // Generate an encrypted random number
    euint8 winningNumber = FHE.random8(); // Hypothetical future Zama API
    
    for (uint i = 0; i < players.size(); i++) {
        address player = players[i];
        ebool isWinner = FHE.eq(tickets[player], winningNumber);
        
        // Distribution logic using FHE.select
        // ...
    }
}
```

## 3. Key Advantages
- **No Front-running**: No one can see the tickets before they are submitted.
- **Provably Fair**: The drawing logic is public, but the inputs (winning number and tickets) are secret.

## 4. Self-Contained References
Check the `references/` folder for:
- `PrivateLottery.sol`: Example contract for an encrypted lottery.
- `LotteryTest.ts`: Testing suite for verifying winner selection.
