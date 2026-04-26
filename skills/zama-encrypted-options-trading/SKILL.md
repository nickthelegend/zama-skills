---
name: Zama Encrypted Options Trading
description: Premium guide to building a private options trading platform on FHEVM. Learn to handle encrypted strike prices, expiration logic, and settlement without revealing positions.
category: blockchain
tags: [fhevm, solidity, trading, options, finance]
---

# Zama Encrypted Options Trading

Encrypted options allow traders to open positions without the market knowing their strike price or volume, preventing predatory front-running and stop-loss hunting.

## 1. Opening a Position

A trader locks collateral and specifies an encrypted strike price.

```solidity
import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract OptionsPlatform is ZamaEthereumConfig {
    struct Position {
        address trader;
        euint32 strikePrice;
        uint256 expiration;
        bool isCall;
    }
    
    mapping(uint256 => Position) public positions;
}
```

## 2. Settlement Logic

At expiration, the platform compares the encrypted strike price with the public market price.

```solidity
function settle(uint256 positionId, uint32 currentMarketPrice) public {
    Position storage p = positions[positionId];
    require(block.timestamp >= p.expiration, "Not expired");
    
    // Convert public price to encrypted for comparison
    euint32 marketPrice = FHE.asEuint32(currentMarketPrice);
    
    ebool isInTheMoney = FHE.gt(marketPrice, p.strikePrice);
    
    // Pay out if in the money
    // ...
}
```

## 3. Advantages of FHE in Trading
- **Dark Pool Mechanics**: Full privacy of the order book.
- **Fair Settlement**: Settlement is calculated on-chain, but the details of who won what can remain private until the payout.

## 4. Self-Contained References
Check the `references/` folder for:
- `ConfidentialOptions.sol`: Implementation of an encrypted options contract.
- `TradingBot.ts`: Example script for interacting with the options platform.
