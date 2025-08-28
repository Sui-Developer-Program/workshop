# Simple Tip Jar DApp

A complete decentralized application built on Sui that allows users to send tips directly to a tip jar owner. The application features gas-free transactions through Enoki sponsorship and a clean, user-friendly interface.

## 🏗️ Project Structure

```
tip_jar/
├── tip_jar_contract/              # Move smart contract
│   ├── Move.toml                  # Contract configuration
│   ├── sources/
│   │   └── tip_jar_contract.move  # Main contract implementation
│   └── tests/
│       └── tip_jar_contract_tests.move # Comprehensive test suite
└── tip_jar_dapp/                  # Next.js frontend
    ├── package.json               # Dependencies and scripts
    ├── src/
    │   ├── app/
    │   │   ├── api/sponsor-transaction/ # Enoki API route
    │   │   ├── layout.tsx          # App layout with providers
    │   │   └── page.tsx           # Main page
    │   ├── components/
    │   │   ├── SuiProvider.tsx    # Sui network provider
    │   │   ├── WalletConnection.tsx # Wallet connection component
    │   │   └── TipJar.tsx         # Main tip jar component
    │   └── hooks/
    │       └── useSponsoredTransaction.ts # Transaction hook
    ├── .env.example               # Environment variables template
    └── .env.local                # Local environment configuration
```

## ✨ Features

### Smart Contract Features
- **Direct Transfers**: Tips are transferred directly to the owner's address
- **Statistics Tracking**: Tracks total tips received and tip count
- **Event Emission**: Emits events for frontend integration
- **Comprehensive Testing**: 9 test cases covering all functionality
- **Security**: Input validation and error handling

### Frontend Features
- **Wallet Integration**: Seamless connection with Sui wallets
- **Real-time Statistics**: Live updates of tip jar statistics
- **Gas-free Transactions**: Enoki-sponsored transactions (API implemented)
- **Responsive Design**: Clean, mobile-friendly interface
- **Error Handling**: Comprehensive error handling and user feedback

## 🚀 Smart Contract

### Core Functionality

The tip jar contract implements a simple but robust tipping system:

```move
/// Send a tip to the tip jar owner
/// The tip is immediately transferred to the owner
/// Only statistics are updated in the shared object
public entry fun send_tip(
    tip_jar: &mut TipJar,
    payment: Coin<SUI>,
    ctx: &mut TxContext,
) {
    let tip_amount = coin::value(&payment);
    assert!(tip_amount > 0, EInvalidTipAmount);
    
    // Transfer payment directly to the tip jar owner
    transfer::public_transfer(payment, tip_jar.owner);
    
    // Update statistics
    tip_jar.total_tips_received = tip_jar.total_tips_received + tip_amount;
    tip_jar.tip_count = tip_jar.tip_count + 1;
    
    // Emit event for frontend tracking
    event::emit(TipSent { /* ... */ });
}
```

### Key Design Decisions

1. **Direct Transfers**: Tips go directly to the owner, no withdrawal needed
2. **Shared Object**: The TipJar object is shared for concurrent access
3. **Event-Driven**: Events enable real-time frontend updates
4. **Minimal Storage**: Only statistics are stored on-chain

### Testing

Comprehensive test suite with 9 test cases:
- Contract initialization
- Basic tip functionality  
- Multiple tips from different users
- Multiple tips from same user
- Zero tip validation
- Event emission
- Getter function validation
- Large tip amounts
- Minimal tip amounts (1 MIST)

Run tests with:
```bash
cd tip_jar_contract
sui move test
```

## 🎨 Frontend Application

### Technology Stack
- **Next.js 15**: Latest React framework with App Router
- **TypeScript**: Full type safety
- **Tailwind CSS**: Utility-first styling
- **Sui TypeScript SDK**: Blockchain interaction
- **Sui dApp Kit**: Wallet integration
- **Enoki**: Sponsored transactions

### Components

#### SuiProvider
Sets up the Sui network configuration and wallet providers:
```typescript
const { networkConfig } = createNetworkConfig({
  testnet: { url: getFullnodeUrl('testnet') },
});
```

#### WalletConnection
Handles wallet connection with clean UI using Sui's ConnectButton component.

#### TipJar
Main application interface featuring:
- Live statistics display
- Tip amount input with validation
- Gas-free transaction indication
- Success/error feedback
- Responsive design

### Sponsored Transactions

Enoki integration provides gas-free transactions:

1. **Backend API** (`/api/sponsor-transaction`):
   - Creates sponsored transactions
   - Executes signed transactions
   - Error handling and validation

2. **Frontend Hook** (`useSponsoredTransaction`):
   - Abstracts transaction sponsorship
   - Provides loading states
   - Success/error callbacks

## 📦 Installation & Setup

### Prerequisites
- Node.js 18+ 
- Sui CLI - [Installation Guide](https://docs.sui.io/guides/developer/getting-started/sui-install)
- Git
- Testnet SUI tokens - [Get from Faucet](https://faucet.sui.io/)

### Smart Contract Setup

1. **Clone and navigate to contract:**
```bash
cd tip_jar_contract
```

2. **Test the contract:**
```bash
sui move test
```

3. **Deploy to testnet:**
```bash
sui client publish --gas-budget 20000000
```

4. **Note the Package ID and TipJar object ID** for frontend configuration

### Frontend Setup

1. **Navigate to frontend:**
```bash
cd tip_jar_dapp
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment:**
```bash
cp .env.example .env.local
```

4. **Update `.env.local` with your values:**
```env
NEXT_PUBLIC_PACKAGE_ID=your_package_id_here
NEXT_PUBLIC_TIP_JAR_ID=your_tip_jar_object_id_here
ENOKI_SECRET_KEY=your_enoki_secret_key_here
```

5. **Start development server:**
```bash
npm run dev
```

## 🔧 Configuration

### Environment Variables

#### Required for Frontend:
- `NEXT_PUBLIC_PACKAGE_ID`: Deployed contract package ID
- `NEXT_PUBLIC_TIP_JAR_ID`: TipJar shared object ID
- `ENOKI_SECRET_KEY`: Enoki API secret key
- `NEXT_PUBLIC_ENOKI_API_URL`: Enoki API endpoint

### Sui Network Configuration
The application is configured for Sui testnet by default. To use mainnet:

1. Update `SuiProvider.tsx` network configuration
2. Update environment variables for mainnet contract addresses
3. Ensure Enoki is configured for mainnet

## 🧪 Testing

### Smart Contract Tests
```bash
cd tip_jar_contract
sui move test
```

All tests pass and cover:
- ✅ Contract initialization
- ✅ Basic tipping functionality
- ✅ Multiple user interactions
- ✅ Input validation
- ✅ Event emission
- ✅ Statistical accuracy
- ✅ Edge cases

### Frontend Testing
The frontend includes TypeScript compilation checks:
```bash
cd tip_jar_dapp
npm run build
```

## 🚀 Deployment

### Smart Contract Deployment

1. **Compile and deploy:**
```bash
sui client publish --gas-budget 20000000
```

2. **Save important addresses:**
   - Package ID
   - TipJar object ID
   - Owner address

### Frontend Deployment

Deploy on Vercel, Netlify, or similar platforms:

1. **Build for production:**
```bash
npm run build
```

2. **Configure environment variables** on your deployment platform

3. **Deploy** using your platform's deployment process

## 📊 Usage

### For Tip Recipients (Owners)

1. Deploy the contract to get your unique tip jar
2. Share your tip jar address with supporters
3. Tips are automatically transferred to your wallet
4. Monitor statistics through the frontend

### For Tippers

1. Visit the tip jar web interface
2. Connect your Sui wallet
3. Enter tip amount in SUI
4. Send tip (gas-free via Enoki)
5. Receive confirmation of successful tip

## 🔐 Security Features

### Smart Contract Security
- Input validation (non-zero tips)
- Direct transfers (no custody risk)
- Minimal storage footprint
- Comprehensive error handling

### Frontend Security
- Environment variable protection
- Input sanitization
- Error boundaries
- Secure API routes

## 🛠️ Development Notes

### Known Issues & TODOs

1. **Error Handling**: Additional user-friendly error messages could be added
2. **Testing**: Frontend unit tests could be added
3. **Mobile Optimization**: Further mobile UX improvements
4. **Coin Selection**: Could be optimized for better coin selection strategy

### Future Enhancements

1. **Multi-Currency Support**: Accept different token types
2. **Tip Messages**: Allow tippers to leave messages
3. **Analytics Dashboard**: Extended statistics and charts
4. **Social Features**: Leaderboards, social sharing
5. **Recurring Tips**: Subscription-based tipping

## 🤝 Contributing

This is an educational project for learning Sui development. Contributions welcome:

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request

## 📝 License

MIT License - feel free to use this code for learning and building your own projects.

## 🎯 Learning Outcomes

This project demonstrates:

### Sui Move Concepts
- ✅ One-time witness pattern
- ✅ Shared objects
- ✅ Direct transfers
- ✅ Event emission
- ✅ Entry functions
- ✅ Comprehensive testing

### Frontend Integration
- ✅ Wallet connectivity
- ✅ Transaction building
- ✅ Real-time data fetching
- ✅ User experience design
- ✅ Error handling

### DeFi Patterns
- ✅ Direct payment flows
- ✅ Statistics tracking
- ✅ Gas sponsorship
- ✅ Event-driven updates

---

Built with ❤️ on Sui • Powered by Enoki for gas-free transactions