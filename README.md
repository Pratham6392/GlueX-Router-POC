# GlueX Router

[![Solidity Version](https://img.shields.io/badge/Solidity-0.8.20-blue)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

GlueX Router is a decentralized exchange (DEX) aggregator router contract that enables efficient token swaps, liquidity management, and cross-chain interactions while maintaining robust security measures.

## 🌟 Key Features

### 🔄 Advanced Swap Mechanisms
- **Multi-Hop Swaps**: Route through multiple liquidity pools for optimal pricing
- **Cross-Chain Support**: Native integration with WETH and bridge protocols
- **Slippage Protection**: Enforce minimum output amounts with deadline constraints
- **Permit2 Integration**: Gasless approvals with EIP-2612 and Dai-style permits

### 💧 Liquidity Management
- **Automated Pool Creation**: Deploy new UniswapV2-style pairs on demand
- **Concentrated Liquidity**: Optimized capital efficiency for liquidity providers
- **Dynamic Fee Tiering**: Support for multiple fee tiers (0.01% - 1%)


### 🔒 Security Architecture
- **Reentrancy Protection**: Built-in guard against reentrancy attacks
- **Input Validation**: Strict parameter checks with custom errors
- **Fee Limitation**: Maximum 0.5% protocol fee cap
- **Emergency Withdrawals**: Treasury-controlled asset recovery

  

## 📦 Installation

```bash
git clone https://github.com/yourusername/gluex-router-poc.git
cd gluex-router-poc
npm install
```


## Testing
```bash
npx hardhat test
```


## Key test coverage
- Token swap execution paths
- Fee calculation accuracy
- Security vulnerability checks
- Edge case handling (zero amounts, max values)
- Reentrancy attack simulations




## My test case 
  Here the test was passing , I made a dummyToken for this case , if you want to run the dummyToken.sol code 
  then just change paths: /test/mocks in Hardhat.congig.js file , and you will be good to go.

![Screenshot 2025-02-04 080048](https://github.com/user-attachments/assets/9aa61665-3e29-4314-aeb9-a67cbff0e8a8)



