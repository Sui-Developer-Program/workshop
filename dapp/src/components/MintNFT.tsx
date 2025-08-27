'use client';

import { useState } from 'react';
import { useCurrentAccount } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { useSponsoredTransaction } from '@/hooks/useSponsoredTransaction';

const PACKAGE_ID = process.env.NEXT_PUBLIC_PACKAGE_ID || '0x0'; // Will be set after deployment

interface MintNFTProps {
  onMintSuccess?: () => void;
}

export function MintNFT({ onMintSuccess }: MintNFTProps) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  
  const { executeSponsoredTransaction, isLoading } = useSponsoredTransaction();
  const currentAccount = useCurrentAccount();

  const mintNFT = async () => {
    if (!currentAccount) {
      alert('Please connect your wallet first');
      return;
    }

    if (!name.trim() || !description.trim() || !imageUrl.trim()) {
      alert('Please fill in all fields');
      return;
    }

    try {
      const tx = new Transaction();
      
      tx.moveCall({
        target: `${PACKAGE_ID}::nft_marketplace::mint_to_sender`,
        arguments: [
          tx.pure.string(name),
          tx.pure.string(description), 
          tx.pure.string(imageUrl),
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('NFT minted successfully:', result);
          alert('NFT minted successfully! (Gas-free transaction)');
          // Clear form
          setName('');
          setDescription('');
          setImageUrl('');
          // Trigger refresh in parent component
          onMintSuccess?.();
        },
        onError: (error) => {
          console.error('Error minting NFT:', error);
          alert('Error minting NFT. Please try again.');
        },
      });
    } catch (error) {
      console.error('Error creating transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  if (!currentAccount) {
    return (
      <div className="bg-white p-6 rounded-lg shadow">
        <p className="text-gray-500">Connect your wallet to mint NFTs</p>
      </div>
    );
  }

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <div className="space-y-4">
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
            NFT Name
          </label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            placeholder="Enter NFT name"
            disabled={isLoading}
          />
        </div>

        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
            Description
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            placeholder="Enter NFT description"
            rows={3}
            disabled={isLoading}
          />
        </div>

        <div>
          <label htmlFor="imageUrl" className="block text-sm font-medium text-gray-700 mb-1">
            Image URL
          </label>
          <input
            type="url"
            id="imageUrl"
            value={imageUrl}
            onChange={(e) => setImageUrl(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            placeholder="https://example.com/image.png"
            disabled={isLoading}
          />
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-center space-x-2 text-sm text-green-600 bg-green-50 py-2 px-3 rounded-md">
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span>Gas-Free Minting Enabled</span>
          </div>
          
          <button
            onClick={mintNFT}
            disabled={isLoading || !name.trim() || !description.trim() || !imageUrl.trim()}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading ? 'Processing (Gas-Free)...' : 'Mint NFT (Free)'}
          </button>
        </div>
      </div>
    </div>
  );
}