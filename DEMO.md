# Zama Skills One-Click Demos

This guide provides commands to deploy and test the 5 featured examples in the `EXAMPLES/` directory.

## 1. Private Counter
```bash
cd EXAMPLES/counter-dapp
npm install
npx hardhat run scripts/deploy.ts --network sepolia
```

## 2. Confidential ERC20 (ERC7984)
```bash
cd EXAMPLES/erc20-dapp
npm install
npx hardhat run scripts/deploy.ts --network sepolia
```

## 3. Confidential Vesting
```bash
cd EXAMPLES/vesting-dapp
npm install
npx hardhat run scripts/deploy.ts --network sepolia
```

## 4. Sealed-Bid Auction
```bash
cd EXAMPLES/auction-dapp
npm install
npx hardhat run scripts/deploy.ts --network sepolia
```

## 5. Private Dutch Auction
```bash
cd EXAMPLES/dutch-auction-dapp
npm install
npx hardhat run scripts/deploy.ts --network sepolia
```

---
*Note: Ensure you have your `PRIVATE_KEY` set in a `.env` file at the root of each example.*
