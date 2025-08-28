import { Transaction } from '@mysten/sui/transactions';
import { MIST_PER_SUI } from '@mysten/sui/utils';
import { suiClient, keypair, CONTRACT_CONFIG, senderAddress } from './config.js';

/**
 * Send a tip to the tip jar
 * @param {number} tipAmountSui - Amount to tip in SUI (e.g., 0.1 for 0.1 SUI)
 */
async function sendTip(tipAmountSui) {
    try {
        console.log(`💰 Sending tip of ${tipAmountSui} SUI...`);
        
        // Convert SUI to MIST (1 SUI = 1_000_000_000 MIST)
        const tipAmountMist = Math.floor(tipAmountSui * Number(MIST_PER_SUI));
        
        if (tipAmountMist <= 0) {
            throw new Error('Tip amount must be greater than 0');
        }
        
        console.log(`   Amount in MIST: ${tipAmountMist}`);
        
        // Create transaction
        const tx = new Transaction();
        
        // Split coin for the tip amount
        const [tipCoin] = tx.splitCoins(tx.gas, [tipAmountMist]);
        
        // Call the send_tip function
        tx.moveCall({
            target: `${CONTRACT_CONFIG.packageId}::${CONTRACT_CONFIG.module}::send_tip`,
            arguments: [
                tx.object(CONTRACT_CONFIG.tipJarObjectId), // tip_jar: &mut TipJar
                tipCoin, // payment: Coin<SUI>
            ],
        });
        
        // Execute transaction
        console.log('📡 Executing transaction...');
        const result = await suiClient.signAndExecuteTransaction({
            signer: keypair,
            transaction: tx,
            options: {
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            },
        });
        
        console.log('✅ Transaction successful!');
        console.log(`   Digest: ${result.digest}`);
        console.log(`   Gas used: ${result.effects.gasUsed.computationCost + result.effects.gasUsed.storageCost + result.effects.gasUsed.storageRebate}`);
        
        // Show events
        if (result.events && result.events.length > 0) {
            console.log('📢 Events emitted:');
            result.events.forEach((event, index) => {
                console.log(`   Event ${index + 1}:`, JSON.stringify(event.parsedJson, null, 2));
            });
        }
        
        return result;
        
    } catch (error) {
        console.error('❌ Error sending tip:', error.message);
        throw error;
    }
}

// CLI usage
if (process.argv.length > 2) {
    const tipAmount = parseFloat(process.argv[2]);
    if (isNaN(tipAmount) || tipAmount <= 0) {
        console.error('Usage: npm run send-tip <amount_in_sui>');
        console.error('Example: npm run send-tip 0.1');
        process.exit(1);
    }
    
    sendTip(tipAmount)
        .then(() => {
            console.log('🎉 Tip sent successfully!');
            process.exit(0);
        })
        .catch(() => {
            process.exit(1);
        });
} else {
    console.error('Usage: npm run send-tip <amount_in_sui>');
    console.error('Example: npm run send-tip 0.1');
    process.exit(1);
}