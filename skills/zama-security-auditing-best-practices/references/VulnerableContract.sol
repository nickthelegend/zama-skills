// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";

contract VulnerableContract {
    mapping(address => euint32) private balances;

    // ❌ VULNERABLE: Leaks info via revert
    function withdraw(uint32 amount) public {
        uint32 clearBal = FHE.decrypt(balances[msg.sender]);
        require(clearBal >= amount, "Insufficient balance"); // Leak!
        // ...
    }

    // ❌ VULNERABLE: Improper ACL
    function grantAccess(euint32 val, address anyone) public {
        FHE.allow(val, anyone); // Too permissive
    }
}
