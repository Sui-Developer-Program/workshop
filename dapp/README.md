# Sui NFT Marketplace dApp with Sponsored Transactions

A full-stack decentralized application built on Sui blockchain for minting, listing, and trading NFTs with **gas-free transactions** powered by Enoki.

## Features

- **Wallet Connection**: Connect to Sui wallets using Sui dApp Kit
- **NFT Minting**: Create new NFTs with name, description, and image URL
- **Marketplace**: List NFTs for sale, purchase NFTs, and remove listings
- **🆓 Sponsored Transactions**: Gas-free operations using Mysten Labs Enoki
- **Automatic Fallback**: Falls back to regular transactions if sponsorship fails
- **Testnet Ready**: Configured to work on Sui testnet

## Gas-Free Operations

Thanks to Enoki integration, users can perform the following operations **without paying gas fees**:
- ✅ Mint NFTs
- ✅ List NFTs for sale
- ✅ Remove listings
- ✅ Purchase NFTs (sponsorship covers transaction fees)

## Prerequisites

1. **Sui CLI**: Install from [Sui documentation](https://docs.sui.io/guides/developer/getting-started/sui-install)
2. **Node.js**: Version 18 or higher
3. **Sui Wallet**: Install a Sui-compatible wallet (Sui Wallet, Suiet, etc.)
4. **Enoki Account**: Sign up at [Enoki Portal](https://portal.enoki.mystenlabs.com/) for sponsored transactions

## Quick Start

### 1. Deploy Smart Contract

```bash
cd ../module3_nft
sui client publish --gas-budget 100000000
```

### 2. Configure Environment

Update `.env.local`:
```bash
NEXT_PUBLIC_PACKAGE_ID=0x_your_package_id_here
NEXT_PUBLIC_MARKETPLACE_ID=0x_your_marketplace_id_here
ENOKI_SECRET_KEY=enoki_private_your_key_here
```

### 3. Setup Enoki

1. Create project at [Enoki Portal](https://portal.enoki.mystenlabs.com/)
2. Get Sponsored Transactions API key
3. Whitelist move call targets for gas-free operations

### 4. Run Application

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## Usage

1. **Connect Wallet**: Click "Connect Wallet" to connect your Sui wallet
2. **Mint NFT**: Fill in NFT details and click "Mint NFT (Free)" - no gas fees!
3. **List NFT**: Select an NFT, set price, and list for sale (gas-free)
4. **Remove Listing**: Remove your listings from marketplace (gas-free)
5. **View Active Listings**: See all your current NFT listings with prices

### Visual Indicators

All operations display clear gas-free indicators:
- 🟢 "Gas-Free Minting Enabled" badge
- 🟢 "Gas-Free Listing" badge  
- 🟢 "(Free)" buttons for sponsored operations
- 🟢 Success messages include "(Gas-free transaction)"

## Architecture

### Smart Contract Integration
- `mint_to_sender`: Mint new NFTs (sponsored)
- `list_for_sale`: List NFTs in marketplace (sponsored)
- `purchase_nft`: Purchase listed NFTs (sponsored)
- `remove_listing`: Remove listings (sponsored)

### Sponsored Transaction Flow
```
User initiates → Build transaction → Send to Enoki API
                                      ↓
Sponsorship success → Execute gas-free → Success!
                 ↓
Sponsorship fails → Fallback to regular → User pays gas
```

## Benefits for Workshops

Perfect for educational environments:
- **No SUI Required**: Students don't need testnet SUI tokens
- **Immediate Engagement**: Users can start trading NFTs instantly
- **Familiar UX**: Web2-like experience with Web3 benefits
- **Educational Value**: Demonstrates sponsored vs regular transactions

## Dependencies

- **Next.js 15**: React framework
- **@mysten/sui**: Sui TypeScript SDK
- **@mysten/dapp-kit**: Sui wallet integration
- **@mysten/enoki**: Enoki SDK for sponsored transactions
- **@tanstack/react-query**: State management
- **Tailwind CSS**: Styling

## Learn More

- [Sui Documentation](https://docs.sui.io/)
- [Enoki Documentation](https://docs.enoki.mystenlabs.com/)
- [Deployment Guide](./DEPLOYMENT.md)

## Troubleshooting

If sponsored transactions aren't working:
1. Check Enoki secret key in `.env.local`
2. Verify move targets are whitelisted in Enoki Portal
3. Ensure sufficient sponsorship credits
4. Check browser console for errors

The app automatically falls back to regular transactions if sponsorship fails.
