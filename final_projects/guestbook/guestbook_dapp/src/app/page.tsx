'use client';

import { useState } from 'react';
import { WalletConnection } from '@/components/WalletConnection';
import { Guestbook } from '@/components/Guestbook';

export default function Home() {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleMessageSuccess = () => {
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Simple Guestbook dApp
          </h1>
          <p className="text-lg text-gray-600">
            Leave a message on Sui with gas-free transactions
          </p>
        </div>
        
        <div className="space-y-6">
          <WalletConnection refreshKey={refreshKey} />
          <Guestbook refreshKey={refreshKey} onMessageSuccess={handleMessageSuccess} />
        </div>

        <footer className="mt-12 text-center text-sm text-gray-500">
          <p>Built with ❤️ on Sui • Powered by Enoki for gas-free transactions</p>
          <div className="mt-2 space-x-4">
            <a 
              href="https://docs.sui.io" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:text-blue-500 transition-colors"
            >
              Sui Docs
            </a>
            <a 
              href="https://docs.enoki.mystenlabs.com" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:text-blue-500 transition-colors"
            >
              Enoki Docs
            </a>
          </div>
        </footer>
      </div>
    </div>
  );
}
