'use client';

import { useState, useEffect } from 'react';
import { useSuiClient, useCurrentAccount } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { useSponsoredTransaction } from '@/hooks/useSponsoredTransaction';

const PACKAGE_ID = process.env.NEXT_PUBLIC_PACKAGE_ID || '0x0';
const TIP_JAR_ID = process.env.NEXT_PUBLIC_TIP_JAR_ID || '0x0';

interface TipJarStats {
  owner: string;
  totalTips: string;
  tipCount: string;
}

interface TipJarProps {
  refreshKey?: number;
  onTipSuccess?: () => void;
}

export function TipJar({ refreshKey = 0, onTipSuccess }: TipJarProps) {
  const [tipAmount, setTipAmount] = useState('');
  const [tipJarStats, setTipJarStats] = useState<TipJarStats | null>(null);

  const { executeSponsoredTransaction, isLoading } = useSponsoredTransaction();
  const client = useSuiClient();
  const currentAccount = useCurrentAccount();

  // Fetch tip jar statistics
  useEffect(() => {
    const fetchTipJarStats = async () => {
      if (!TIP_JAR_ID || TIP_JAR_ID === '0x0') return;

      try {
        const tipJarObject = await client.getObject({
          id: TIP_JAR_ID,
          options: {
            showContent: true,
          },
        });

        if (tipJarObject.data?.content && 'fields' in tipJarObject.data.content) {
          const fields = tipJarObject.data.content.fields as Record<string, unknown>;
          setTipJarStats({
            owner: String(fields.owner || ''),
            totalTips: String(fields.total_tips_received || '0'),
            tipCount: String(fields.tip_count || '0'),
          });
        }
      } catch (error) {
        console.error('Error fetching tip jar stats:', error);
      }
    };

    fetchTipJarStats();
  }, [client, refreshKey]);

  const sendTip = async () => {
    if (!currentAccount || !tipAmount || !PACKAGE_ID || !TIP_JAR_ID) {
      alert('Please connect wallet, enter tip amount, and ensure contract is configured');
      return;
    }

    const tipInMist = Math.floor(parseFloat(tipAmount) * 1_000_000_000); // Convert SUI to MIST
    if (tipInMist <= 0) {
      alert('Please enter a valid tip amount');
      return;
    }

    try {
      const tx = new Transaction();
      
      // Get user's SUI coins
      const coins = await client.getCoins({
        owner: currentAccount.address,
        coinType: '0x2::sui::SUI',
      });

      if (!coins.data.length) {
        alert('No SUI coins found in wallet');
        return;
      }

      // Find a coin with sufficient balance or use the largest coin
      let selectedCoin = coins.data[0];
      for (const coin of coins.data) {
        if (parseInt(coin.balance) >= tipInMist) {
          selectedCoin = coin;
          break;
        }
        if (parseInt(coin.balance) > parseInt(selectedCoin.balance)) {
          selectedCoin = coin;
        }
      }

      if (parseInt(selectedCoin.balance) < tipInMist) {
        alert(`Insufficient balance. Need ${tipAmount} SUI but largest coin has ${(parseInt(selectedCoin.balance) / 1_000_000_000).toFixed(4)} SUI`);
        return;
      }

      // Split coin for the tip amount
      const [tipCoin] = tx.splitCoins(tx.object(selectedCoin.coinObjectId), [tipInMist]);

      // Call the send_tip function
      tx.moveCall({
        target: `${PACKAGE_ID}::tip_jar_contract::send_tip`,
        arguments: [
          tx.object(TIP_JAR_ID),
          tipCoin,
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('Tip sent successfully:', result);
          alert(`Tip of ${tipAmount} SUI sent successfully! (Gas-free transaction)`);
          setTipAmount('');
          onTipSuccess?.(); // Refresh stats and balance
        },
        onError: (error) => {
          console.error('Error sending tip:', error);
          const errorMessage = error instanceof Error ? error.message : String(error);
          alert(`Error sending tip: ${errorMessage}`);
        },
      });
    } catch (error) {
      console.error('Error creating tip transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  if (!currentAccount) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">💰 Simple Tip Jar</h2>
        <p className="text-gray-600">Please connect your wallet to send tips.</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">💰 Simple Tip Jar</h2>

      {/* Tip Jar Statistics */}
      {tipJarStats && (
        <div className="bg-gray-50 rounded-lg p-4 mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Statistics</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center">
              <p className="text-2xl font-bold text-blue-600">
                {(parseInt(tipJarStats.totalTips) / 1_000_000_000).toFixed(3)}
              </p>
              <p className="text-sm text-gray-600">Total SUI Received</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-green-600">{tipJarStats.tipCount}</p>
              <p className="text-sm text-gray-600">Number of Tips</p>
            </div>
            <div className="text-center">
              <p className="text-xs text-gray-500 break-all">
                Owner: {tipJarStats.owner.slice(0, 8)}...{tipJarStats.owner.slice(-6)}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Send Tip Section */}
      <div className="space-y-4">
        <div>
          <label htmlFor="tip-amount" className="block text-sm font-medium text-gray-700 mb-1">
            Tip Amount (SUI)
          </label>
          <input
            type="number"
            id="tip-amount"
            value={tipAmount}
            onChange={(e) => setTipAmount(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
            placeholder="0.1"
            step="0.001"
            min="0"
            disabled={isLoading}
          />
        </div>

        <div className="flex items-center justify-center space-x-2 text-sm text-green-600 bg-green-50 py-2 px-3 rounded-md">
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
          </svg>
          <span>Gas-Free Transaction via Enoki</span>
        </div>

        <button
          onClick={sendTip}
          disabled={isLoading || !tipAmount || parseFloat(tipAmount) <= 0}
          className="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
        >
          {isLoading ? 'Sending Tip (Gas-Free)...' : 'Send Tip (Free)'}
        </button>
      </div>

      {/* Instructions */}
      <div className="mt-6 bg-blue-50 border border-blue-200 p-4 rounded-lg">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">How it works</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Enter the amount you want to tip in SUI</li>
          <li>• Click &quot;Send Tip&quot; to send your tip</li>
          <li>• All transactions are sponsored (gas-free) via Enoki</li>
          <li>• Tips are sent directly to the tip jar owner</li>
        </ul>
      </div>
    </div>
  );
}