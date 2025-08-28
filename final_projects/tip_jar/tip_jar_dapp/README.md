# Tip Jar Frontend DApp

A Next.js frontend application for the Tip Jar smart contract, featuring wallet integration, gas-free transactions via Enoki sponsorship, and real-time statistics display.

## 📋 Prerequisites

- Node.js 18+
- Deployed Tip Jar contract (Package ID and TipJar Object ID)
- [Enoki API](https://portal.enoki.mystenlabs.com) key for sponsored transactions

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env.local
```

### 3. Update Environment Variables

Edit `.env.local` with your values:

```env
NEXT_PUBLIC_PACKAGE_ID=your_package_id_here
NEXT_PUBLIC_TIP_JAR_ID=your_tip_jar_object_id_here
ENOKI_SECRET_KEY=your_enoki_secret_key_here
NEXT_PUBLIC_ENOKI_API_URL=https://enoki-api.sui.io
```

### 4. Start Development Server

```bash
npm run dev
```

Visit `http://localhost:3000` to see your tip jar in action!

## 🎯 Features

### Core Functionality

- **Wallet Integration**: Connect with Sui wallets seamlessly
- **Gas-Free Transactions**: Enoki-sponsored transactions for better UX
- **Real-time Statistics**: Live updates of tip counts and totals
- **Responsive Design**: Mobile-friendly interface
- **Error Handling**: Comprehensive error feedback

### Technical Stack

- **Next.js 15**: React framework with App Router
- **TypeScript**: Full type safety
- **Tailwind CSS**: Utility-first styling
- **Sui TypeScript SDK**: Blockchain interaction
- **Sui dApp Kit**: Wallet connectivity
- **Enoki**: Transaction sponsorship

## 📁 Project Structure

```
src/
├── app/
│   ├── api/sponsor-transaction/  # Enoki API route
│   ├── layout.tsx               # App layout with providers
│   └── page.tsx                # Main page
├── components/
│   ├── SuiProvider.tsx         # Sui network configuration
│   ├── WalletConnection.tsx    # Wallet connection UI
│   └── TipJar.tsx             # Main tip jar interface
└── hooks/
    └── useSponsoredTransaction.ts # Transaction hook
```

## 🔧 Configuration

### Required Environment Variables

- `NEXT_PUBLIC_PACKAGE_ID`: Your deployed contract's package ID
- `NEXT_PUBLIC_TIP_JAR_ID`: The TipJar shared object ID
- `ENOKI_SECRET_KEY`: Your Enoki API secret key (server-side only)
- `NEXT_PUBLIC_ENOKI_API_URL`: Enoki API endpoint

### Network Configuration

The app is configured for Sui testnet by default. To use mainnet:

1. Update network config in `SuiProvider.tsx`
2. Update environment variables for mainnet addresses
3. Configure Enoki for mainnet

## 🚀 Deployment

### Build for Production

```bash
npm run build
```

### Deploy on Vercel

1. Connect your repository to Vercel
2. Configure environment variables in Vercel dashboard
3. Deploy automatically on push

### Other Platforms

The app can be deployed on any platform supporting Next.js:

- Netlify
- Railway
- Digital Ocean App Platform
- AWS Amplify

## 🧪 Testing

### Type Checking

```bash
npm run build
```

### Development Testing

1. Connect a testnet wallet
2. Ensure you have testnet SUI tokens
3. Test tipping functionality
4. Verify statistics updates

## 📊 Usage

### For Users

1. Visit the deployed application
2. Connect your Sui wallet
3. Enter tip amount in SUI
4. Send tip (gas-free!)
5. View updated statistics

### For Developers

The app demonstrates:

- Sui wallet integration patterns
- Transaction building and execution
- Real-time blockchain data fetching
- Sponsored transaction implementation
- Modern React/Next.js patterns

## 🔐 Security

- Environment variables are properly scoped (client vs server)
- Input validation on tip amounts
- Secure API routes for transaction sponsorship
- Error boundaries for graceful error handling

## 🛠️ Development Notes

### Key Components

- **TipJar**: Main interface with statistics and tip functionality
- **WalletConnection**: Handles wallet connectivity
- **SuiProvider**: Network and wallet configuration
- **useSponsoredTransaction**: Abstracts sponsored transaction logic

### API Route

The `/api/sponsor-transaction` endpoint handles:

- Creating sponsored transactions
- Executing signed transactions
- Error handling and validation

## 📚 Learn More

This frontend demonstrates:

- Sui dApp development patterns
- Wallet integration best practices
- Transaction sponsorship implementation
- Modern React patterns with Next.js
- TypeScript in blockchain applications

---

Part of the Sui Development Workshop series
