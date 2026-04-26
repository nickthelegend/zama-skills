---
name: Zama Sepolia Deployment and Testing
description: Guide to deploying confidential smart contracts to the Zama Sepolia testnet and running live tests using Hardhat
category: blockchain
tags: [fhevm, solidity, sepolia, deployment, testing]
---

# Zama Sepolia Deployment and Testing

Deploying to Sepolia allows you to test your confidential contracts on a live network that supports Zama's FHEVM operations and Gateway.

## 1. Configuration

Ensure your `hardhat.config.ts` is configured for Sepolia:

```typescript
sepolia: {
  accounts: {
    mnemonic: vars.get("MNEMONIC"),
    path: "m/44'/60'/0'/0/",
    count: 10,
  },
  chainId: 11155111,
  url: `https://sepolia.infura.io/v3/${vars.get("INFURA_API_KEY")}`,
}
```

## 2. Setting Environment Variables

Set your mnemonic and API keys using Hardhat vars:

```bash
npx hardhat vars set MNEMONIC "your secret mnemonic"
npx hardhat vars set INFURA_API_KEY "your_infura_key"
```

## 3. Deployment

Use the `hardhat-deploy` plugin to deploy your contracts. Create a script in `deploy/deploy.ts`:

```typescript
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
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

Run the deployment command:

```bash
npx hardhat deploy --network sepolia
```

## 4. Testing on Sepolia

Testing on a live network requires the `@fhevm/hardhat-plugin` to interact with the Zama Gateway for decryption.

```typescript
describe("FHECounterSepolia", function () {
  it("increment the counter on Sepolia", async function () {
    const deployment = await deployments.get("FHECounter");
    const contract = await ethers.getContractAt("FHECounter", deployment.address);
    const [alice] = await ethers.getSigners();

    // Encrypt input for Sepolia
    const encryptedInput = await fhevm
      .createEncryptedInput(deployment.address, alice.address)
      .add32(1)
      .encrypt();

    // Send transaction
    const tx = await contract.connect(alice).increment(
      encryptedInput.handles[0],
      encryptedInput.inputProof
    );
    await tx.wait();

    // Decrypt result via Gateway
    const encryptedCount = await contract.getCount();
    const clearCount = await fhevm.userDecryptEuint(
      FhevmType.euint32,
      encryptedCount,
      deployment.address,
      alice
    );
    
    console.log("Current count on Sepolia:", clearCount);
  });
});
```

Run tests with the network flag:

```bash
npx hardhat test --network sepolia test/FHECounterSepolia.ts
```

## 5. Zama Sepolia Faucet

You will need Sepolia ETH and ZAMA tokens (for gas on the Gateway chain).
Visit the [Zama Faucet](https://faucet.zama.ai/) to get test tokens.
