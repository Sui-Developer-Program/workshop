'use client';

import { useState } from 'react';
import { WalletConnection } from '@/components/WalletConnection';
import { TipJar } from '@/components/TipJar';

export default function Home() {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleTipSuccess = () => {
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-2xl mx-auto px-4">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Simple Tip Jar DApp
          </h1>
          <p className="text-lg text-gray-600">
            Send tips on Sui with gas-free transactions powered by Enoki
          </p>
        </div>
        
        <div className="space-y-6">
          <WalletConnection refreshKey={refreshKey} />
          <TipJar refreshKey={refreshKey} onTipSuccess={handleTipSuccess} />
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
