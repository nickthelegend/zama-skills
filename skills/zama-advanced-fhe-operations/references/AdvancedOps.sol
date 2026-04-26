// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

contract AdvancedOps is ZamaEthereumConfig {
    function bitwiseDemo(euint32 a, euint32 b) public pure returns (euint32, euint32) {
        euint32 xorRes = FHE.xor(a, b);
        euint32 andRes = FHE.and(a, b);
        return (xorRes, andRes);
    }

    function mathDemo(euint32 a, euint32 b) public pure returns (euint32, euint32) {
        euint32 divRes = FHE.div(a, b);
        euint32 remRes = FHE.rem(a, b);
        return (divRes, remRes);
    }

    function selectDemo(ebool cond, euint32 a, euint32 b) public pure returns (euint32) {
        return FHE.select(cond, a, b);
    }

    function shiftDemo(euint32 a) public pure returns (euint32) {
        return FHE.shl(a, 4);
    }
}
