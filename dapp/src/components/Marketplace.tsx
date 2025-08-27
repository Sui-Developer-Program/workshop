'use client';

import { useState, useEffect } from 'react';
import { useSuiClient, useCurrentAccount } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { useSponsoredTransaction } from '@/hooks/useSponsoredTransaction';

const PACKAGE_ID = process.env.NEXT_PUBLIC_PACKAGE_ID || '0x0';
const MARKETPLACE_ID = process.env.NEXT_PUBLIC_MARKETPLACE_ID || '0x0';

interface NFT {
  id: string;
  name: string;
  description: string;
  image_url: string;
  creator: string;
}

interface Listing {
  id: string;
  nft_id: string;
  nft_name: string;
  price: string;
  seller: string;
}

interface MarketplaceProps {
  refreshKey?: number;
  onListingChange?: () => void;
}

export function Marketplace({ refreshKey = 0, onListingChange }: MarketplaceProps) {
  const [userNFTs, setUserNFTs] = useState<NFT[]>([]);
  const [userListings, setUserListings] = useState<Listing[]>([]);
  const [selectedNFT, setSelectedNFT] = useState<string>('');
  const [listingPrice, setListingPrice] = useState('');

  const { executeSponsoredTransaction, isLoading } = useSponsoredTransaction();
  const client = useSuiClient();
  const currentAccount = useCurrentAccount();

  // Fetch user's NFTs and listings
  useEffect(() => {
    const fetchUserData = async () => {
      if (!currentAccount) return;

      try {
        // Fetch user's NFTs
        const objects = await client.getOwnedObjects({
          owner: currentAccount.address,
          filter: {
            StructType: `${PACKAGE_ID}::nft_marketplace::WorkshopNFT`,
          },
          options: {
            showContent: true,
            showDisplay: true,
          },
        });

        const nfts: NFT[] = objects.data
          .map((obj) => {
            const content = obj.data?.content;
            if (content && 'fields' in content) {
              const fields = content.fields as any;
              return {
                id: obj.data!.objectId,
                name: fields.name || 'Unknown',
                description: fields.description || 'No description',
                image_url: fields.image_url || '',
                creator: fields.creator || '',
              };
            }
            return null;
          })
          .filter(Boolean) as NFT[];

        setUserNFTs(nfts);

        // Fetch marketplace to get user's listings
        await fetchUserListings();
      } catch (error) {
        console.error('Error fetching user data:', error);
      }
    };

    const fetchUserListings = async () => {
      if (!currentAccount) return;

      try {
        // Get dynamic fields (listings) from the marketplace
        const dynamicFields = await client.getDynamicFields({
          parentId: MARKETPLACE_ID,
        });

        const userListings: Listing[] = [];

        // Fetch each listing to check if it belongs to the current user
        for (const field of dynamicFields.data) {
          try {
            const listing = await client.getDynamicFieldObject({
              parentId: MARKETPLACE_ID,
              name: field.name,
            });

            if (listing.data?.content && 'fields' in listing.data.content) {
              const listingFields = listing.data.content.fields as any;
              
              // Check if this listing belongs to the current user
              if (listingFields.seller === currentAccount.address) {
                // Use the field name value as the listing ID (which is the actual listing ID)
                const listingId = typeof field.name.value === 'string' ? field.name.value : field.name.value.toString();
                
                userListings.push({
                  id: listingId,
                  nft_id: listingFields.nft?.fields?.id?.id || 'Unknown',
                  nft_name: listingFields.nft?.fields?.name || 'Unknown NFT',
                  price: listingFields.price || '0',
                  seller: listingFields.seller,
                });
              }
            }
          } catch (error) {
            // Skip this listing if there's an error fetching it
            console.log('Skipping listing due to error:', error);
          }
        }

        setUserListings(userListings);
      } catch (error) {
        console.error('Error fetching user listings:', error);
      }
    };

    fetchUserData();
  }, [currentAccount, client, refreshKey]);

  const listNFTForSale = async () => {
    if (!currentAccount || !selectedNFT || !listingPrice) {
      alert('Please select an NFT and enter a price');
      return;
    }

    const priceInMist = Math.floor(parseFloat(listingPrice) * 1_000_000_000); // Convert SUI to MIST
    if (priceInMist <= 0) {
      alert('Please enter a valid price');
      return;
    }

    try {
      const tx = new Transaction();
      
      tx.moveCall({
        target: `${PACKAGE_ID}::nft_marketplace::list_for_sale`,
        arguments: [
          tx.object(MARKETPLACE_ID),
          tx.object(selectedNFT),
          tx.pure.u64(priceInMist),
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('NFT listed successfully:', result);
          alert('NFT listed for sale successfully! (Gas-free transaction)');
          setSelectedNFT('');
          setListingPrice('');
          onListingChange?.(); // Refresh the data
        },
        onError: (error) => {
          console.error('Error listing NFT:', error);
          alert('Error listing NFT. Please try again.');
        },
      });
    } catch (error) {
      console.error('Error creating listing transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  const removeNFTListing = async (listingId: string) => {
    if (!currentAccount) return;

    try {
      const tx = new Transaction();
      
      tx.moveCall({
        target: `${PACKAGE_ID}::nft_marketplace::remove_listing`,
        arguments: [
          tx.object(MARKETPLACE_ID),
          tx.pure.id(listingId),
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('Listing removed successfully:', result);
          alert('Listing removed successfully! (Gas-free transaction)');
          onListingChange?.(); // Refresh the data
        },
        onError: (error) => {
          console.error('Error removing listing:', error);
          alert('Error removing listing. Please try again.');
        },
      });
    } catch (error) {
      console.error('Error creating remove transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  const purchaseNFT = async (listingId: string, price: string) => {
    if (!currentAccount) return;

    try {
      const tx = new Transaction();
      
      // Split coin for exact payment
      const [coin] = tx.splitCoins(tx.gas, [tx.pure.u64(price)]);
      
      tx.moveCall({
        target: `${PACKAGE_ID}::nft_marketplace::purchase_nft`,
        arguments: [
          tx.object(MARKETPLACE_ID),
          tx.pure.id(listingId),
          coin,
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('NFT purchased successfully:', result);
          alert('NFT purchased successfully! (Gas-free transaction)');
          onListingChange?.(); // Refresh the data
        },
        onError: (error) => {
          console.error('Error purchasing NFT:', error);
          alert('Error purchasing NFT. Please try again.');
        },
      });
    } catch (error) {
      console.error('Error creating purchase transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  if (!currentAccount) {
    return (
      <div className="bg-white p-6 rounded-lg shadow">
        <p className="text-gray-500">Connect your wallet to access the marketplace</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* List NFT Section */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4 text-gray-900">List Your NFT</h3>
        
        {userNFTs.length === 0 ? (
          <p className="text-gray-500">You don't have any NFTs to list</p>
        ) : (
          <div className="space-y-4">
            <div>
              <label htmlFor="nft-select" className="block text-sm font-medium text-gray-700 mb-1">
                Select NFT
              </label>
              <select
                id="nft-select"
                value={selectedNFT}
                onChange={(e) => setSelectedNFT(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 bg-white"
                disabled={isLoading}
              >
                <option value="">Choose an NFT</option>
                {userNFTs.map((nft) => (
                  <option key={nft.id} value={nft.id}>
                    {nft.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="price" className="block text-sm font-medium text-gray-700 mb-1">
                Price (SUI)
              </label>
              <input
                type="number"
                id="price"
                value={listingPrice}
                onChange={(e) => setListingPrice(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
                placeholder="0.1"
                step="0.001"
                min="0"
                disabled={isLoading}
              />
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-center space-x-2 text-sm text-green-600 bg-green-50 py-2 px-3 rounded-md">
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                <span>Gas-Free Listing</span>
              </div>
              
              <button
                onClick={listNFTForSale}
                disabled={isLoading || !selectedNFT || !listingPrice}
                className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
              >
                {isLoading ? 'Processing (Gas-Free)...' : 'List for Sale (Free)'}
              </button>
            </div>
          </div>
        )}
      </div>

      {/* User's Active Listings */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4 text-gray-900">Your Active Listings</h3>
        
        {userListings.length === 0 ? (
          <p className="text-gray-500">You have no active listings</p>
        ) : (
          <div className="space-y-3">
            {userListings.map((listing) => (
              <div key={listing.id} className="flex justify-between items-center p-3 border rounded-lg bg-gray-50">
                <div>
                  <h4 className="font-medium text-gray-900">{listing.nft_name}</h4>
                  <p className="text-blue-600 font-medium">
                    {(parseInt(listing.price) / 1_000_000_000).toFixed(3)} SUI
                  </p>
                </div>
                <button
                  onClick={() => removeNFTListing(listing.id)}
                  disabled={isLoading}
                  className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700 disabled:bg-gray-400 transition-colors"
                >
                  {isLoading ? 'Removing (Free)...' : 'Remove (Free)'}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Instructions Section */}
      <div className="bg-blue-50 border border-blue-200 p-6 rounded-lg">
        <h3 className="text-lg font-semibold mb-4 text-blue-900">How to Use</h3>
        <div className="space-y-2 text-blue-800">
          <p>1. <strong>Mint NFTs</strong> using the form on the left</p>
          <p>2. <strong>List your NFTs</strong> for sale using the form above</p>
          <p>3. <strong>Manage listings</strong> in the &quot;Your Active Listings&quot; section</p>
          <p>4. <strong>Remove listings</strong> to get your NFTs back</p>
        </div>
      </div>
    </div>
  );
}