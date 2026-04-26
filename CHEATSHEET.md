# Zama FHEVM Cheat Sheet (v4.0)

The ultimate quick-reference for Zama FHEVM developers.

## 1. Address Book

| Component | Network | Address / URL |
| :--- | :--- | :--- |
| **RPC Endpoint** | Sepolia | `https://rpc.sepolia.zama.ai` |
| **ACL Contract** | Sepolia | `0x848B0066793BcC60346Da1F49049357399B8D595` |
| **KMS Public Key** | Sepolia | `https://gateway.sepolia.zama.ai/pubkey` |
| **Faucet** | Sepolia | `https://faucet.zama.ai` |

## 2. Common FHE Operators

| Operator | Usage | Returns |
| :--- | :--- | :--- |
| `FHE.fromExternal` | `FHE.fromExternal(ext, proof)` | `euintX` |
| `FHE.select` | `FHE.select(ebool, a, b)` | `euintX` |
| `FHE.gt` | `FHE.gt(a, b)` | `ebool` |
| `FHE.add` | `FHE.add(a, b)` | `euintX` |
| `FHE.shl` | `FHE.shl(a, bits)` | `euintX` |
| `FHE.allow` | `FHE.allow(handle, user)` | `void` |
| `FHE.allowThis` | `FHE.allowThis(handle)` | `void` |

## 3. Hardware & L2 Integration
- **HPU (Hardware Processing Unit)**: When targeting HPU-enabled networks, avoid `euint64` unless necessary, as `euint32` batching is significantly more optimized on current hardware.
- **Layer 2**: FHEVM on L2 (e.g. Optimism) requires the `L2FHEVMExecutor` contract. See the `zama-fhevm-layer2-optimism-integration` skill for bridge details.

## 4. Security Patterns
- **The "No-Branch" Rule**: Never use `if (ebool)`. Always use `FHE.select`.
- **Callback Security**:
```solidity
function callback(uint256 reqId, uint32 result) public {
    require(msg.sender == gatewayAddress, "Unauthorized");
    require(requests[reqId].pending, "Already processed");
    // ...
}
```

## 5. Relayer SDK Quick Start
```typescript
import { createInstance } from "fhevmjs";
const instance = await createInstance({ chainId: 11155111, publicKey: "..." });
const { handles, inputProof } = await instance.createEncryptedInput(contract, user).add32(100).encrypt();
```
