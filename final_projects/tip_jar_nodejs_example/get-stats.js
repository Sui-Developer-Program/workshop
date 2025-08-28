import { MIST_PER_SUI } from '@mysten/sui/utils';
import { suiClient, CONTRACT_CONFIG } from './config.js';

/**
 * Get tip jar statistics
 */
async function getTipJarStats() {
    try {
        console.log('📊 Fetching tip jar statistics...');
        
        // Get the tip jar object
        const tipJarObject = await suiClient.getObject({
            id: CONTRACT_CONFIG.tipJarObjectId,
            options: {
                showContent: true,
                showType: true,
            },
        });
        
        if (!tipJarObject.data) {
            throw new Error('Tip jar object not found');
        }
        
        // Parse the object data
        const fields = tipJarObject.data.content.fields;
        
        console.log('📈 Tip Jar Statistics:');
        console.log(`   Owner: ${fields.owner}`);
        console.log(`   Total tips received: ${fields.total_tips_received} MIST (${fields.total_tips_received / Number(MIST_PER_SUI)} SUI)`);
        console.log(`   Number of tips: ${fields.tip_count}`);
        
        if (fields.tip_count > 0) {
            const avgTip = fields.total_tips_received / fields.tip_count;
            console.log(`   Average tip: ${avgTip} MIST (${avgTip / Number(MIST_PER_SUI)} SUI)`);
        }
        
        return {
            owner: fields.owner,
            totalTipsReceived: fields.total_tips_received,
            tipCount: fields.tip_count,
            totalTipsReceivedSUI: fields.total_tips_received / Number(MIST_PER_SUI),
            averageTipSUI: fields.tip_count > 0 ? (fields.total_tips_received / fields.tip_count) / Number(MIST_PER_SUI) : 0
        };
        
    } catch (error) {
        console.error('❌ Error fetching statistics:', error.message);
        throw error;
    }
}

/**
 * Get recent tip events
 * @param {number} limit - Number of events to fetch (default: 10)
 */
async function getRecentTipEvents(limit = 10) {
    try {
        console.log(`📜 Fetching last ${limit} tip events...`);
        
        // Query events
        const events = await suiClient.queryEvents({
            query: {
                MoveModule: {
                    package: CONTRACT_CONFIG.packageId,
                    module: CONTRACT_CONFIG.module
                }
            },
            limit,
            order: 'descending'
        });
        
        if (events.data.length === 0) {
            console.log('   No tip events found');
            return [];
        }
        
        console.log(`📋 Recent Tips:`);
        events.data.forEach((event, index) => {
            const eventData = event.parsedJson;
            console.log(`   ${index + 1}. Amount: ${eventData.tip_amount} MIST (${eventData.tip_amount / Number(MIST_PER_SUI)} SUI)`);
            console.log(`      Tipper: ${eventData.tipper}`);
            console.log(`      Timestamp: ${new Date(Number(event.timestampMs)).toISOString()}`);
            console.log(`      Transaction: ${event.id.txDigest}`);
            console.log('');
        });
        
        return events.data;
        
    } catch (error) {
        console.error('❌ Error fetching events:', error.message);
        throw error;
    }
}

// CLI usage
if (import.meta.url === `file://${process.argv[1]}`) {
    Promise.all([
        getTipJarStats(),
        getRecentTipEvents(5)
    ])
    .then(() => {
        console.log('✅ Statistics fetched successfully!');
        process.exit(0);
    })
    .catch(() => {
        process.exit(1);
    });
}