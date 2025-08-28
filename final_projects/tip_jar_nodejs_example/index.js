import { suiClient, CONTRACT_CONFIG, senderAddress } from './config.js';

/**
 * Main example script showing basic usage
 */
async function main() {
    console.log('🚀 Tip Jar NodeJS Example');
    console.log('==========================');
    
    try {
        // Check balance
        console.log('💳 Checking wallet balance...');
        const balance = await suiClient.getBalance({
            owner: senderAddress,
        });
        
        console.log(`   Balance: ${balance.totalBalance} MIST (${balance.totalBalance / 1_000_000_000} SUI)`);
        
        if (balance.totalBalance === '0') {
            console.log('⚠️  Warning: Your wallet has no SUI balance.');
            console.log('   Please get some testnet SUI from: https://faucet.sui.io/');
            return;
        }
        
        // Check if tip jar exists
        console.log('🏺 Verifying tip jar contract...');
        const tipJarObject = await suiClient.getObject({
            id: CONTRACT_CONFIG.tipJarObjectId,
            options: { showContent: true }
        });
        
        if (!tipJarObject.data) {
            throw new Error('Tip jar object not found. Please check your TIP_JAR_OBJECT_ID.');
        }
        
        console.log('✅ Tip jar contract found and accessible!');
        
        // Show current stats
        const fields = tipJarObject.data.content.fields;
        console.log('📊 Current Statistics:');
        console.log(`   Owner: ${fields.owner}`);
        console.log(`   Total tips: ${fields.total_tips_received} MIST`);
        console.log(`   Tip count: ${fields.tip_count}`);
        
        console.log('');
        console.log('🎯 Available Commands:');
        console.log('   npm run send-tip <amount>  - Send a tip (e.g., npm run send-tip 0.1)');
        console.log('   npm run get-stats          - Get current statistics and recent events');
        console.log('');
        console.log('📚 Example Usage:');
        console.log('   npm run send-tip 0.05      # Send 0.05 SUI tip');
        console.log('   npm run send-tip 1.5       # Send 1.5 SUI tip');
        console.log('   npm run get-stats           # View statistics');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        
        if (error.message.includes('not found')) {
            console.log('💡 Make sure you have:');
            console.log('   1. Deployed the tip jar contract');
            console.log('   2. Set correct PACKAGE_ID and TIP_JAR_OBJECT_ID in .env');
            console.log('   3. Set a valid PRIVATE_KEY in .env');
        }
        
        process.exit(1);
    }
}

// Run if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}