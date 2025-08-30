'use client';

import { useState, useEffect } from 'react';
import { useSuiClient, useCurrentAccount } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { useSponsoredTransaction } from '@/hooks/useSponsoredTransaction';

const PACKAGE_ID = process.env.NEXT_PUBLIC_PACKAGE_ID || '0x0';
const GUESTBOOK_ID = process.env.NEXT_PUBLIC_GUESTBOOK_ID || '0x0';

interface Message {
  sender: string;
  content: string;
}

interface GuestbookStats {
  messages: Message[];
  numberOfMessages: string;
}

interface GuestbookProps {
  refreshKey?: number;
  onMessageSuccess?: () => void;
}

export function Guestbook({ refreshKey = 0, onMessageSuccess }: GuestbookProps) {
  const [messageContent, setMessageContent] = useState('');
  const [guestbookStats, setGuestbookStats] = useState<GuestbookStats | null>(null);
  const [isLoadingMessages, setIsLoadingMessages] = useState(false);

  const { executeSponsoredTransaction, isLoading } = useSponsoredTransaction();
  const client = useSuiClient();
  const currentAccount = useCurrentAccount();

  const MAX_LENGTH = 100;

  useEffect(() => {
    const fetchMessages = async () => {
      if (!GUESTBOOK_ID || GUESTBOOK_ID === '0x0') return;

      setIsLoadingMessages(true);
      try {
        const guestbookObject = await client.getObject({
          id: GUESTBOOK_ID,
          options: {
            showContent: true,
          },
        });

        if (guestbookObject.data?.content && 'fields' in guestbookObject.data.content) {
          const fields = guestbookObject.data.content.fields as Record<string, unknown>;

          const messages = fields.messages as Array<{
            fields: { sender: string; content: string }
          }> || [];

          setGuestbookStats({
            messages: messages.map(msg => ({
              sender: msg.fields.sender,
              content: msg.fields.content
            })).reverse(),
            numberOfMessages: String(fields.number_of_messages || '0'),
          });
        }
      } catch (error) {
        console.error('Error fetching guestbook:', error);
      } finally {
        setIsLoadingMessages(false);
      }
    };

    fetchMessages();
  }, [client, refreshKey]);

  const postMessage = async () => {
    if (!currentAccount || !messageContent.trim() || !PACKAGE_ID || !GUESTBOOK_ID) {
      alert('Please connect wallet, enter a message, and ensure contract is configured');
      return;
    }

    if (messageContent.length > MAX_LENGTH) {
      alert(`Message too long! Maximum ${MAX_LENGTH} characters allowed.`);
      return;
    }

    try {
      const tx = new Transaction();

      const messageBytes = new TextEncoder().encode(messageContent.trim());

      console.log(messageBytes)

      const [message] = tx.moveCall({
        target: `${PACKAGE_ID}::guestbook_contract::create_message`,
        arguments: [
          tx.pure.vector('u8', messageBytes),
        ],
      });

      tx.moveCall({
        target: `${PACKAGE_ID}::guestbook_contract::post_message`,
        arguments: [
          tx.object(GUESTBOOK_ID),
          message,
        ],
      });

      await executeSponsoredTransaction(tx, {
        onSuccess: (result) => {
          console.log('Message posted successfully:', result);
          alert('Message posted successfully! (Gas-free transaction)');
          setMessageContent('');
          onMessageSuccess?.();
        },
        onError: (error) => {
          console.error('Error posting message:', error);
          const errorMessage = error instanceof Error ? error.message : String(error);
          alert(`Error posting message: ${errorMessage}`);
        },
      });
    } catch (error) {
      console.error('Error creating message transaction:', error);
      alert('Error creating transaction. Please try again.');
    }
  };

  if (!currentAccount) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">📝 Guestbook</h2>
        <p className="text-gray-600">Please connect your wallet to post messages.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">📝 Post a Message</h2>

        <div className="space-y-4">
          <div>
            <label htmlFor="message-content" className="block text-sm font-medium text-gray-700 mb-1">
              Your Message ({messageContent.length}/{MAX_LENGTH} characters)
            </label>
            <textarea
              id="message-content"
              value={messageContent}
              onChange={(e) => setMessageContent(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 resize-none"
              placeholder="Leave a message in the guestbook..."
              rows={3}
              maxLength={MAX_LENGTH}
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
            onClick={postMessage}
            disabled={isLoading || !messageContent.trim() || messageContent.length > MAX_LENGTH}
            className="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading ? 'Posting Message (Gas-Free)...' : 'Post Message (Free)'}
          </button>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-gray-900">💬 Messages</h2>
          {guestbookStats && (
            <span className="bg-blue-100 text-blue-800 text-sm font-medium px-3 py-1 rounded-full">
              {guestbookStats.numberOfMessages} total messages
            </span>
          )}
        </div>

        {isLoadingMessages ? (
          <div className="text-center py-8">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            <p className="mt-2 text-gray-600">Loading messages...</p>
          </div>
        ) : guestbookStats && guestbookStats.messages.length > 0 ? (
          <div className="space-y-4 max-h-96 overflow-y-auto">
            {guestbookStats.messages.map((message, index) => (
              <div key={index} className="border-l-4 border-blue-500 pl-4 py-2 bg-gray-50 rounded-r-lg">
                <p className="text-gray-900 mb-1">{message.content}</p>
                <p className="text-xs text-gray-500">
                  From: {message.sender.slice(0, 8)}...{message.sender.slice(-6)}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-8 text-gray-500">
            <p>No messages yet. Be the first to sign the guestbook!</p>
          </div>
        )}
      </div>

      <div className="bg-blue-50 border border-blue-200 p-4 rounded-lg">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">How it works</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Write your message (up to 100 characters)</li>
          <li>• Click &quot;Post Message&quot; to add it to the guestbook</li>
          <li>• All transactions are sponsored (gas-free) via Enoki</li>
          <li>• Messages are stored permanently on the Sui blockchain</li>
        </ul>
      </div>
    </div>
  );
}