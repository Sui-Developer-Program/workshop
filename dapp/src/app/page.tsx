'use client';

import { useState, useCallback } from 'react';
import { WalletButton } from '@/components/WalletButton';
import { MintNFT } from '@/components/MintNFT';
import { Marketplace } from '@/components/Marketplace';

export default function Home() {
  const [refreshKey, setRefreshKey] = useState(0);
  
  const triggerRefresh = useCallback(() => {
    setRefreshKey(prev => prev + 1);
  }, []);
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <h1 className="text-3xl font-bold text-gray-900">Sui NFT Marketplace</h1>
            <WalletButton />
          </div>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div>
            <h2 className="text-2xl font-semibold mb-6 text-gray-900">Mint NFT</h2>
            <MintNFT onMintSuccess={triggerRefresh} />
          </div>
          
          <div>
            <h2 className="text-2xl font-semibold mb-6 text-gray-900">Marketplace</h2>
            <Marketplace refreshKey={refreshKey} onListingChange={triggerRefresh} />
          </div>
        </div>
      </main>
    </div>
  );
}
