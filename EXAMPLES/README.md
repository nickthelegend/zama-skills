# Zama Skills: Working Examples

This directory contains fully functional, self-contained DApps built with Zama FHEVM. Each example includes a Hardhat project for the contracts and a React/Vite frontend.

## Featured Examples
1. **counter-dapp**: Basic encrypted state management.
2. **erc20-dapp**: Full ERC7984 confidential token implementation.
3. **auction-dapp**: Sealed-bid auction mechanics.
4. **vesting-dapp**: Private token vesting schedules.
5. **dutch-auction-dapp**: Hidden price descending auctions.

## One-Click Setup
Each example follows the same setup flow:
```bash
cd <example-folder>
npm install
# Create .env with PRIVATE_KEY
npx hardhat run scripts/deploy.ts --network sepolia
```
