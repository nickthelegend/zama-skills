// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract FHEWordle is ZamaEthereumConfig {
    euint8[5] private secretWord;
    mapping(address => euint8[5]) private playerFeedback;
    mapping(address => uint256) public attempts;

    constructor(uint8[5] memory _secret) {
        for(uint i=0; i<5; i++) {
            secretWord[i] = FHE.asEuint8(_secret[i]);
            FHE.allowThis(secretWord[i]);
        }
    }

    function submitGuess(uint8[5] calldata guess) public {
        attempts[msg.sender]++;
        
        for (uint i = 0; i < 5; i++) {
            euint8 secretChar = secretWord[i];
            uint8 guessChar = guess[i];
            
            // Check Green
            ebool isGreen = FHE.eq(secretChar, guessChar);
            
            // Simplified logic: 2 = Green, 0 = Otherwise
            playerFeedback[msg.sender][i] = FHE.select(isGreen, FHE.asEuint8(2), FHE.asEuint8(0));
            
            FHE.allow(playerFeedback[msg.sender][i], msg.sender);
            FHE.allowThis(playerFeedback[msg.sender][i]);
        }
    }

    function getFeedback() public view returns (euint8[5] memory) {
        return playerFeedback[msg.sender];
    }
}
