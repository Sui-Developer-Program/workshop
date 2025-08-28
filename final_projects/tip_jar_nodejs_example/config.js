import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import dotenv from 'dotenv';

dotenv.config();

// Validate required environment variables
const requiredEnvVars = ['PRIVATE_KEY', 'PACKAGE_ID', 'TIP_JAR_OBJECT_ID'];
for (const envVar of requiredEnvVars) {
    if (!process.env[envVar]) {
        throw new Error(`Missing required environment variable: ${envVar}`);
    }
}

// Network configuration
const network = process.env.SUI_NETWORK || 'testnet';
const rpcUrl = process.env.SUI_RPC_URL || getFullnodeUrl(network);

// Initialize Sui client
export const suiClient = new SuiClient({ url: rpcUrl });

// Initialize keypair from private key
export const keypair = Ed25519Keypair.fromSecretKey(
    process.env.PRIVATE_KEY
);

// Contract configuration
export const CONTRACT_CONFIG = {
    packageId: process.env.PACKAGE_ID,
    tipJarObjectId: process.env.TIP_JAR_OBJECT_ID,
    module: 'tip_jar_contract',
    network: network
};

// Get sender address
export const senderAddress = keypair.getPublicKey().toSuiAddress();

console.log(`🔧 Configuration loaded:`);
console.log(`   Network: ${network}`);
console.log(`   RPC URL: ${rpcUrl}`);
console.log(`   Sender: ${senderAddress}`);
console.log(`   Package: ${CONTRACT_CONFIG.packageId}`);
console.log(`   TipJar: ${CONTRACT_CONFIG.tipJarObjectId}`);