/// Comprehensive tests for the token smart contract
/// Tests cover all major functionality: minting, burning, transfers, and access control
#[test_only]
module module2_token::my_token_tests {
    use sui::test_scenario::{Self, next_tx, ctx};
    use sui::coin::{Self, Coin, TreasuryCap};
    use module2_token::my_token::{Self, MY_TOKEN};
    
    const ADMIN: address = @0xAD;
    const ALICE: address = @0xA11CE;
    const BOB: address = @0xB0B;
    
    #[test]
    fun test_init() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize the token - this calls the init function
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        // Check that treasury cap was transferred to admin
        next_tx(&mut scenario, ADMIN);
        {
            assert!(test_scenario::has_most_recent_for_sender<TreasuryCap<MY_TOKEN>>(&scenario), 0);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_mint_tokens() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize the token
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        // Admin mints tokens for Alice
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            
            // Test initial supply is 0
            assert!(my_token::total_supply(&treasury_cap) == 0, 1);
            
            // Mint 1000 tokens for Alice
            my_token::mint(&mut treasury_cap, 1000, ALICE, ctx(&mut scenario));
            
            // Check total supply increased
            assert!(my_token::total_supply(&treasury_cap) == 1000, 2);
            
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Check that Alice received the tokens
        next_tx(&mut scenario, ALICE);
        {
            let coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            assert!(my_token::coin_value(&coin) == 1000, 3);
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_transfer_tokens() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Setup: Initialize and mint tokens for Alice
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            my_token::mint(&mut treasury_cap, 1000, ALICE, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Alice transfers 300 tokens to Bob
        next_tx(&mut scenario, ALICE);
        {
            let mut coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            let transfer_coin = my_token::split_coin(&mut coin, 300, ctx(&mut scenario));
            my_token::transfer_tokens(transfer_coin, BOB, ctx(&mut scenario));
            
            // Alice should have 700 tokens left
            assert!(my_token::coin_value(&coin) == 700, 4);
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        // Check that Bob received 300 tokens
        next_tx(&mut scenario, BOB);
        {
            let coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            assert!(my_token::coin_value(&coin) == 300, 5);
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_burn_tokens() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Setup: Initialize and mint tokens
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            my_token::mint(&mut treasury_cap, 1000, ALICE, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Alice sends some tokens back to admin for burning
        next_tx(&mut scenario, ALICE);
        {
            let mut coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            let burn_coin = my_token::split_coin(&mut coin, 200, ctx(&mut scenario));
            my_token::transfer_tokens(burn_coin, ADMIN, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        // Admin burns the tokens
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            let burn_coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            
            // Check total supply before burning
            assert!(my_token::total_supply(&treasury_cap) == 1000, 6);
            
            // Burn 200 tokens
            my_token::burn(&mut treasury_cap, burn_coin);
            
            // Check total supply decreased
            assert!(my_token::total_supply(&treasury_cap) == 800, 7);
            
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_join_coins() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Setup: Initialize and mint tokens - create two separate coins
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            my_token::mint(&mut treasury_cap, 500, ALICE, ctx(&mut scenario));
            my_token::mint(&mut treasury_cap, 300, ALICE, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Alice joins her two coins
        next_tx(&mut scenario, ALICE);
        {
            let coin_ids = test_scenario::ids_for_sender<Coin<MY_TOKEN>>(&scenario);
            let mut coin1 = test_scenario::take_from_sender_by_id<Coin<MY_TOKEN>>(&scenario, *vector::borrow(&coin_ids, 0));
            let coin2 = test_scenario::take_from_sender_by_id<Coin<MY_TOKEN>>(&scenario, *vector::borrow(&coin_ids, 1));
            
            // Join the coins
            my_token::join_coins(&mut coin1, coin2);
            
            // Check that the joined coin has the total value
            assert!(my_token::coin_value(&coin1) == 800, 8);
            
            test_scenario::return_to_sender(&scenario, coin1);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_split_and_join_operations() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Setup
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            my_token::mint(&mut treasury_cap, 1000, ALICE, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Alice performs multiple split and join operations
        next_tx(&mut scenario, ALICE);
        {
            let mut coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            
            // Split into two parts: 400 and 600
            let split_coin = my_token::split_coin(&mut coin, 400, ctx(&mut scenario));
            assert!(my_token::coin_value(&coin) == 600, 9);
            assert!(my_token::coin_value(&split_coin) == 400, 10);
            
            // Join them back together
            my_token::join_coins(&mut coin, split_coin);
            assert!(my_token::coin_value(&coin) == 1000, 11);
            
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    #[expected_failure(abort_code = sui::balance::ENotEnough)]
    fun test_split_insufficient_balance() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Setup
        {
            my_token::test_init(ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, ADMIN);
        {
            let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<MY_TOKEN>>(&scenario);
            my_token::mint(&mut treasury_cap, 100, ALICE, ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, treasury_cap);
        };
        
        // Alice tries to split more than she has - this should fail
        next_tx(&mut scenario, ALICE);
        {
            let mut coin = test_scenario::take_from_sender<Coin<MY_TOKEN>>(&scenario);
            
            // This should fail - trying to split 200 from a coin with only 100
            let split_coin = my_token::split_coin(&mut coin, 200, ctx(&mut scenario));
            
            // Clean up (though this won't execute due to abort)
            my_token::join_coins(&mut coin, split_coin);
            test_scenario::return_to_sender(&scenario, coin);
        };
        
        test_scenario::end(scenario);
    }
}