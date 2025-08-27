# Deployment Guide for Sui NFT Marketplace dApp

This guide walks you through deploying the Module 3 NFT marketplace smart contract to Sui testnet and configuring the frontend dApp.

## Prerequisites

1. **Sui CLI installed**: Follow [Sui installation guide](https://docs.sui.io/guides/developer/getting-started/sui-install)
2. **Sui testnet setup**: Configure your Sui client for testnet
3. **Testnet SUI tokens**: Get testnet SUI from the [Sui Discord faucet](https://discord.gg/sui)
4. **Enoki Developer Account**: Sign up at [Enoki Portal](https://portal.enoki.mystenlabs.com/) for sponsored transactions

## Step 1: Configure Sui CLI for Testnet

```bash
# Check current environment
sui client envs

# Switch to testnet (or add if not present)
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443
sui client switch --env testnet

# Check your address and get testnet SUI
sui client active-address
```

Visit the [Sui Discord](https://discord.gg/sui) #devnet-faucet channel and request testnet SUI:
```
!faucet <your-sui-address>
```

## Step 2: Deploy the Smart Contract

Navigate to the Module 3 NFT directory and deploy:

```bash
cd module3_nft
sui client publish --gas-budget 100000000
```

**Important**: Save the deployment output! You'll need:
- **Package ID**: Look for "Package published at" in the output
- **Marketplace Object ID**: Look for the shared object of type "Marketplace"

Example output:
```
Package published at 0x123abc...
Created Objects:
  - ID: 0x456def... , Owner: Shared
    Type: 0x123abc...::nft_marketplace::Marketplace
```

## Step 3: Configure Enoki Sponsored Transactions

### 3.1 Set up Enoki Project
1. Go to [Enoki Portal](https://portal.enoki.mystenlabs.com/)
2. Create a new project
3. Navigate to **API Keys** section
4. Create a **Sponsored Transactions** API key (private key for backend)
5. Copy the private key for your environment configuration

### 3.2 Configure Sponsored Transaction Rules
1. In your Enoki project, go to **Sponsored Transactions**
2. Add the following move call targets (replace `{PACKAGE_ID}` with your actual package ID):
   ```
   {PACKAGE_ID}::nft_marketplace::mint_to_sender
   {PACKAGE_ID}::nft_marketplace::list_for_sale
   {PACKAGE_ID}::nft_marketplace::purchase_nft
   {PACKAGE_ID}::nft_marketplace::remove_listing
   ```
3. Set appropriate spending limits and rules as needed

## Step 4: Update Frontend Configuration

Update the `.env.local` file in the dapp directory:

```bash
cd ../dapp
```

Edit `.env.local`:
```bash
# Smart Contract Configuration
NEXT_PUBLIC_PACKAGE_ID=0x123abc... # Your package ID from deployment
NEXT_PUBLIC_MARKETPLACE_ID=0x456def... # Your marketplace object ID

# Enoki Sponsored Transactions (Backend only - keep secure!)
ENOKI_SECRET_KEY=enoki_private_your_key_here
```

**Important**: Keep your Enoki private key secure and never expose it to the frontend!

## Step 5: Install Dependencies and Run

```bash
npm install
npm run dev
```

## Step 6: Test the dApp

1. Open http://localhost:3000
2. Connect your Sui wallet
3. Ensure your wallet is connected to testnet
4. Try minting an NFT (should be gas-free!)
5. List the NFT for sale (should be gas-free!)
6. Remove listing (should be gas-free!)
7. Test purchasing with a different wallet

### Expected Behavior with Enoki:
- **Gas-Free Operations**: All transactions (mint, list, remove) should show "Gas-Free" indicators
- **Automatic Fallback**: If sponsorship fails, transactions will fall back to regular gas payment
- **Success Messages**: Look for "(Gas-free transaction)" in success alerts

## Troubleshooting

### Common Issues

1. **"Insufficient gas" error (when fallback occurs)**
   - Ensure you have enough testnet SUI for fallback transactions
   - Request more from the Discord faucet

2. **"Object not found" error**
   - Double-check the Package ID and Marketplace ID in `.env.local`
   - Ensure you're connected to testnet in your wallet

3. **Transaction fails**
   - Check that your wallet is connected to testnet
   - Verify the smart contract deployment was successful

4. **Sponsored transactions not working**
   - Verify your Enoki secret key is correct in `.env.local`
   - Check that move call targets are whitelisted in Enoki Portal
   - Ensure you have sufficient sponsorship credits in your Enoki project
   - Check browser console for API error messages

5. **API route errors**
   - Make sure the Enoki secret key starts with `enoki_private_`
   - Verify your Enoki project is configured for testnet
   - Check Next.js server logs for detailed error messages

### Verifying Deployment

You can verify your deployment using Sui Explorer:
1. Go to [Sui Testnet Explorer](https://suiexplorer.com/?network=testnet)
2. Search for your Package ID
3. Verify the contract code and shared objects

### Getting Testnet SUI

If you need more testnet SUI:
1. Join [Sui Discord](https://discord.gg/sui)
2. Go to #devnet-faucet channel
3. Use command: `!faucet <your-address>`
4. Wait for confirmation

## Production Deployment

For mainnet deployment:

1. **Switch to mainnet**:
   ```bash
   sui client switch --env mainnet
   ```

2. **Deploy with real SUI**:
   ```bash
   sui client publish --gas-budget 100000000
   ```

3. **Update environment**:
   - Change network in `layout.tsx` from "testnet" to "mainnet"
   - Update `.env.local` with mainnet contract addresses

4. **Deploy frontend**:
   - Use Vercel, Netlify, or your preferred hosting platform
   - Ensure environment variables are set in production

## Next Steps

- Implement additional features (royalties, collections, etc.)
- Add more comprehensive error handling
- Implement real-time marketplace updates
- Add NFT metadata validation
- Consider implementing a backend for caching and indexing