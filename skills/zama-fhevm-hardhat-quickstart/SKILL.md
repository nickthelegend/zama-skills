---
name: Zama FHEVM Hardhat Quickstart
description: Premium guide to set up and deploy your first confidential Solidity contract on Sepolia. Self-contained with all necessary configs and examples.
category: blockchain
tags: [fhevm, solidity, sepolia, hardhat, quickstart]
---

# Zama FHEVM Hardhat Quickstart

This guide provides everything you need to start building confidential smart contracts using Zama's FHEVM.

## 1. Environment Setup

The FHEVM requires a specific Hardhat environment to handle encrypted types and the Gateway communication.

### Prerequisites
- Node.js v18+
- npm or pnpm
- A wallet with Sepolia ETH (get some at [faucet.zama.ai](https://faucet.zama.ai/))

### Project Initialization
```bash
# Clone the template (or reference the files in this skill)
npx hardhat init
# Install Zama specific dependencies
npm install @fhevm/hardhat-plugin @fhevm/solidity hardhat-deploy
```

## 2. Core Configuration (`hardhat.config.ts`)

Your `hardhat.config.ts` must include the `@fhevm/hardhat-plugin`.

```typescript
import "@fhevm/hardhat-plugin";
import "hardhat-deploy";
import { vars } from "hardhat/config";

const config = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${vars.get("INFURA_API_KEY")}`,
      accounts: [vars.get("PRIVATE_KEY")],
      chainId: 11155111,
    }
  }
};
export default config;
```

## 3. Writing Your First Contract (`FHECounter.sol`)

Confidential contracts use `euint` (encrypted unsigned integer) types.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint32, externalEuint32} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract FHECounter is ZamaEthereumConfig {
    euint32 private _count;

    function getCount() external view returns (euint32) {
        return _count;
    }

    function increment(externalEuint32 input, bytes calldata proof) external {
        euint32 encryptedInput = FHE.fromExternal(input, proof);
        _count = FHE.add(_count, encryptedInput);
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
    }
}
```

## 4. Deployment (`deploy/deploy.ts`)

Use `hardhat-deploy` for a seamless experience.

```typescript
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("FHECounter", {
    from: deployer,
    args: [],
    log: true,
  });
};
export default func;
```

## 5. Testing and Interaction

Run tests locally using the FHEVM mock environment:
```bash
npx hardhat test
```

Deploy to Sepolia:
```bash
npx hardhat deploy --network sepolia
```

## 6. Self-Contained References
Check the `references/` folder in this skill for:
- `FHECounter.sol`: Complete contract source.
- `hardhat.config.ts`: Production-ready config.
- `deploy.ts`: Automated deployment script.
- `package.json`: Dependency list.
