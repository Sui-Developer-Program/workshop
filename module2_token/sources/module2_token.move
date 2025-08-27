/// Module: module2_token
/// A simple token implementation demonstrating Sui Move patterns from Module 2
/// Key concepts: one-time witness, capabilities, token creation, transfer, resource management
module module2_token::my_token {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::url;
    
    /// The one-time witness used to create the token
    public struct MY_TOKEN has drop {}
    
    /// Module initializer is called once at publication
    /// Creates the token currency and transfers treasury capability to the sender
    fun init(witness: MY_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<MY_TOKEN>(
            witness,
            9, // decimals
            b"WORKSHOP", // symbol
            b"Workshop Token", // name
            b"A token created in the Sui developer workshop", // description
            option::some(url::new_unsafe_from_bytes(b"https://sui.io")), // icon url
            ctx
        );
        
        // Freeze the metadata to prevent further changes
        transfer::public_freeze_object(metadata);
        
        // Transfer the treasury capability to the publisher (admin)
        transfer::public_transfer(treasury_cap, ctx.sender());
    }
    
    /// Mint new tokens - requires treasury capability
    /// This demonstrates capability-based access control
    public fun mint(
        treasury_cap: &mut TreasuryCap<MY_TOKEN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
    }
    
    /// Burn tokens - requires treasury capability  
    /// This demonstrates resource management
    public fun burn(
        treasury_cap: &mut TreasuryCap<MY_TOKEN>,
        coin: Coin<MY_TOKEN>
    ) {
        coin::burn(treasury_cap, coin);
    }
    
    /// Transfer tokens from one address to another
    /// This demonstrates basic token transfer functionality
    public fun transfer_tokens(
        coin: Coin<MY_TOKEN>,
        recipient: address,
        _ctx: &mut TxContext
    ) {
        transfer::public_transfer(coin, recipient);
    }
    
    /// Split a coin into two coins with specified amounts
    /// This demonstrates coin manipulation
    public fun split_coin(
        coin: &mut Coin<MY_TOKEN>,
        split_amount: u64,
        ctx: &mut TxContext
    ): Coin<MY_TOKEN> {
        coin::split(coin, split_amount, ctx)
    }
    
    /// Join two coins together
    /// This demonstrates coin combination
    public fun join_coins(
        coin1: &mut Coin<MY_TOKEN>,
        coin2: Coin<MY_TOKEN>
    ) {
        coin::join(coin1, coin2);
    }
    
    /// Get the total supply of the token
    /// Requires treasury capability to access this information
    public fun total_supply(treasury_cap: &TreasuryCap<MY_TOKEN>): u64 {
        coin::total_supply(treasury_cap)
    }
    
    /// Get the value (amount) of a coin
    public fun coin_value(coin: &Coin<MY_TOKEN>): u64 {
        coin::value(coin)
    }
    
    /// Test-only function to initialize the module for testing
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(MY_TOKEN {}, ctx);
    }
}