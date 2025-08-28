# Tip Jar Smart Contract

A Sui Move smart contract that enables direct tipping functionality. Tips are immediately transferred to the owner's wallet while maintaining statistics on a shared object.

## 📋 Prerequisites

- Sui CLI - [Installation Guide](https://docs.sui.io/guides/developer/getting-started/sui-install)
- Testnet SUI tokens - [Get from Faucet](https://faucet.sui.io/)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd tip_jar_contract
```

### 2. Build Contract
```bash
sui move build
```

### 3. Run Tests
```bash
sui move test
```

All 9 tests should pass ✅

### 4. Deploy to Testnet
```bash
sui client publish --gas-budget 20000000
```

### 5. Save Important Information
After deployment, note down:
- **Package ID**: Required for frontend integration
- **TipJar Object ID**: The shared object ID from deployment
- **Owner Address**: Your wallet address that will receive tips

## 📦 Contract Features

- **Direct Transfers**: Tips go immediately to owner's wallet
- **Statistics Tracking**: Total tips received and tip count
- **Event Emission**: Events for frontend integration
- **Input Validation**: Ensures non-zero tip amounts
- **Shared Object**: Concurrent access for multiple users

## 🧪 Test Coverage

The contract includes comprehensive tests:
- Contract initialization
- Basic tipping functionality
- Multiple user interactions
- Input validation (zero tips rejected)
- Event emission verification
- Statistical accuracy
- Edge cases (large/minimal amounts)

## 🔧 Integration

After deployment, use the Package ID and TipJar Object ID in your frontend application to enable tipping functionality.

## 📚 Learn More

This contract demonstrates key Sui Move concepts:
- One-time witness pattern
- Shared objects
- Direct transfers
- Event emission
- Entry functions

---

Part of the Sui Development Workshop series