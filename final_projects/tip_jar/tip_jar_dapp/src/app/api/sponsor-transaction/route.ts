import { NextRequest, NextResponse } from 'next/server';
import { EnokiClient } from '@mysten/enoki';

const enoki = new EnokiClient({
  apiKey: process.env.ENOKI_SECRET_KEY!,
});

export async function POST(request: NextRequest) {
  try {
    const { action, txBytes, userAddress, signature, digest } = await request.json();

    if (action === 'create') {
      // Step 1: Create sponsored transaction
      if (!txBytes || !userAddress) {
        return NextResponse.json(
          { error: 'Missing required fields: txBytes, userAddress' },
          { status: 400 }
        );
      }

      const sponsoredTx = await enoki.createSponsoredTransaction({
        network: 'testnet',
        transactionKindBytes: txBytes,
        sender: userAddress,
        allowedMoveCallTargets: [
          `${process.env.NEXT_PUBLIC_PACKAGE_ID}::tip_jar_contract::send_tip`,
        ],
        allowedAddresses: [userAddress],
      });

      return NextResponse.json({
        sponsoredTransaction: sponsoredTx,
        success: true
      });

    } else if (action === 'execute') {
      // Step 2: Execute sponsored transaction with user signature
      if (!signature || !digest) {
        return NextResponse.json(
          { error: 'Missing required fields: signature, digest' },
          { status: 400 }
        );
      }

      const result = await enoki.executeSponsoredTransaction({
        digest,
        signature,
      });

      return NextResponse.json({
        result,
        success: true
      });
    } else {
      return NextResponse.json(
        { error: 'Invalid action. Use "create" or "execute"' },
        { status: 400 }
      );
    }

  } catch (error) {
    console.error('Error with sponsored transaction:', error);
    
    return NextResponse.json(
      { 
        error: 'Failed to process sponsored transaction',
        details: error instanceof Error ? error.message : 'Unknown error',
        message: 'Transaction sponsorship failed. The transaction may not be whitelisted or there may be a configuration issue.'
      },
      { status: 500 }
    );
  }
}