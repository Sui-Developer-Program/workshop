/// Module: tip_jar_contract
/// Simple tip jar that transfers tips directly to the owner
/// Tips are immediately sent to owner, only statistics are stored in the contract
module tip_jar_contract::tip_jar_contract;

use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

/// Error codes
const EInvalidTipAmount: u64 = 1;

/// The main TipJar shared object that tracks statistics
/// Tips are not stored here - they go directly to the owner
public struct TipJar has key {
    id: UID,
    owner: address,
    total_tips_received: u64,
    tip_count: u64,
}

/// Event emitted when a tip is sent
public struct TipSent has copy, drop {
    tipper: address,
    amount: u64,
    total_tips: u64,
    tip_count: u64,
}

/// Event emitted when tip jar is created
public struct TipJarCreated has copy, drop {
    tip_jar_id: ID,
    owner: address,
}

/// Initialize the tip jar - creates a shared TipJar object
#[allow(unused_function)]
fun init(ctx: &mut TxContext) {
    let owner = ctx.sender();
    let tip_jar = TipJar {
        id: object::new(ctx),
        owner,
        total_tips_received: 0,
        tip_count: 0,
    };

    let tip_jar_id = object::id(&tip_jar);

    // Emit creation event
    event::emit(TipJarCreated {
        tip_jar_id,
        owner,
    });

    // Share the tip jar so anyone can send tips
    transfer::share_object(tip_jar);
}

/// Send a tip to the tip jar owner
/// The tip is immediately transferred to the owner
/// Only statistics are updated in the shared object
public fun send_tip(tip_jar: &mut TipJar, payment: Coin<SUI>, ctx: &mut TxContext) {
    let tip_amount = coin::value(&payment);

    // Ensure tip amount is greater than zero
    assert!(tip_amount > 0, EInvalidTipAmount);

    // Transfer payment directly to the tip jar owner
    transfer::public_transfer(payment, tip_jar.owner);

    // Update statistics in the tip jar
    tip_jar.total_tips_received = tip_jar.total_tips_received + tip_amount;
    tip_jar.tip_count = tip_jar.tip_count + 1;

    // Emit event for the frontend to track
    event::emit(TipSent {
        tipper: ctx.sender(),
        amount: tip_amount,
        total_tips: tip_jar.total_tips_received,
        tip_count: tip_jar.tip_count,
    });
}

/// Get the total amount of tips received by the owner
public fun get_total_tips(tip_jar: &TipJar): u64 {
    tip_jar.total_tips_received
}

/// Get the total number of tips sent
public fun get_tip_count(tip_jar: &TipJar): u64 {
    tip_jar.tip_count
}

/// Get the owner address of the tip jar
public fun get_owner(tip_jar: &TipJar): address {
    tip_jar.owner
}

/// Check if an address is the owner of the tip jar
public fun is_owner(tip_jar: &TipJar, addr: address): bool {
    tip_jar.owner == addr
}

#[test_only]
/// Test-only function to initialize tip jar for tests
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}
