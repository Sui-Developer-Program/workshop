'use client';

import { useState } from 'react';
import { useSignTransaction, useSignAndExecuteTransaction, useSuiClient, useCurrentAccount } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import { fromBase64, toBase64 } from '@mysten/sui/utils';

interface SponsoredTransactionOptions {
  onSuccess?: (result: unknown) => void;
  onError?: (error: unknown) => void;
}

export function useSponsoredTransaction() {
  const [isLoading, setIsLoading] = useState(false);
  const { mutateAsync: signTransaction } = useSignTransaction();
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const client = useSuiClient();
  const currentAccount = useCurrentAccount();

  const executeSponsoredTransaction = async (
    transaction: Transaction,
    options: SponsoredTransactionOptions = {}
  ) => {
    if (!currentAccount) {
      options.onError?.(new Error('No account connected'));
      return;
    }

    setIsLoading(true);

    try {
      // Build transaction bytes (transaction kind only)
      const txBytes = await transaction.build({ 
        client, 
        onlyTransactionKind: true 
      });

      // Convert to base64 for API
      const txBytesBase64 = toBase64(txBytes);

      // Step 1: Create sponsored transaction
      const createResponse = await fetch('/api/sponsor-transaction', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'create',
          txBytes: txBytesBase64,
          userAddress: currentAccount.address,
        }),
      });

      const createData = await createResponse.json();

      if (createResponse.ok && createData.sponsoredTransaction) {
        const { sponsoredTransaction } = createData;
        console.log('Sponsored transaction created:', sponsoredTransaction);

        try {
          // Step 2: User signs the sponsored transaction
          const sponsoredTxBytes = fromBase64(sponsoredTransaction.bytes);
          const signatureResult = await signTransaction({
            transaction: Transaction.from(sponsoredTxBytes),
          });

          // Step 3: Execute sponsored transaction with user signature
          const executeResponse = await fetch('/api/sponsor-transaction', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              action: 'execute',
              digest: sponsoredTransaction.digest,
              signature: signatureResult.signature,
            }),
          });

          const executeData = await executeResponse.json();

          if (executeResponse.ok) {
            console.log('Sponsored transaction executed successfully:', executeData.result);
            options.onSuccess?.(executeData.result);
          } else {
            throw new Error(executeData.message || executeData.error || 'Failed to execute sponsored transaction');
          }
        } catch (signError) {
          console.error('Error signing or executing sponsored transaction:', signError);
          // Fallback to regular transaction
          console.warn('Falling back to regular transaction');
          executeRegularTransaction(transaction, options);
        }
      } else {
        // Sponsorship creation failed, fallback to regular transaction
        console.warn('Transaction sponsorship creation failed:', createData.message || createData.error);
        console.warn('Falling back to regular transaction');
        executeRegularTransaction(transaction, options);
      }
    } catch (error) {
      console.error('Error in sponsored transaction flow:', error);
      // Fallback to regular transaction
      console.warn('Falling back to regular transaction');
      executeRegularTransaction(transaction, options);
    } finally {
      setIsLoading(false);
    }
  };

  const executeRegularTransaction = (
    transaction: Transaction,
    options: SponsoredTransactionOptions
  ) => {
    signAndExecute(
      {
        transaction,
      },
      {
        onSuccess: options.onSuccess,
        onError: options.onError,
      }
    );
  };

  return {
    executeSponsoredTransaction,
    isLoading,
  };
}