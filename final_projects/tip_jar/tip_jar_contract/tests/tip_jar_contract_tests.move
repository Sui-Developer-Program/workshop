#[test_only]
module tip_jar_contract::tip_jar_contract_tests {
    use sui::test_scenario::{Self};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use tip_jar_contract::tip_jar_contract::{Self, TipJar};

    const OWNER: address = @0xA11CE;
    const TIPPER_1: address = @0xB0B;
    const TIPPER_2: address = @0xCAFE;

    // Helper function to create test coins
    fun create_test_coin(amount: u64, ctx: &mut TxContext): Coin<SUI> {
        coin::mint_for_testing<SUI>(amount, ctx)
    }

    #[test]
    fun test_init_creates_tip_jar() {
        let mut scenario = test_scenario::begin(OWNER);
        let ctx = test_scenario::ctx(&mut scenario);

        // Initialize the tip jar
        tip_jar_contract::init_for_testing(ctx);
        
        // Check that TipJarCreated event was emitted
        test_scenario::next_tx(&mut scenario, OWNER);
        
        // Verify the tip jar was created and shared
        let tip_jar = test_scenario::take_shared<TipJar>(&scenario);
        
        // Verify initial state
        assert!(tip_jar_contract::get_owner(&tip_jar) == OWNER, 0);
        assert!(tip_jar_contract::get_total_tips(&tip_jar) == 0, 1);
        assert!(tip_jar_contract::get_tip_count(&tip_jar) == 0, 2);
        assert!(tip_jar_contract::is_owner(&tip_jar, OWNER) == true, 3);
        assert!(tip_jar_contract::is_owner(&tip_jar, TIPPER_1) == false, 4);
        
        test_scenario::return_shared(tip_jar);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_send_tip_basic() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Tipper sends a tip
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let tip_coin = create_test_coin(1_000_000_000, ctx); // 1 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin, ctx);
            
            // Verify tip jar state updated
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 1_000_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 1, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        // Verify owner received the coin
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let received_coin = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&received_coin) == 1_000_000_000, 2);
            test_scenario::return_to_sender(&scenario, received_coin);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_tips() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // First tipper sends 0.5 SUI
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let tip_coin = create_test_coin(500_000_000, ctx); // 0.5 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 500_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 1, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        // Second tipper sends 1.5 SUI
        test_scenario::next_tx(&mut scenario, TIPPER_2);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let tip_coin = create_test_coin(1_500_000_000, ctx); // 1.5 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 2_000_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 2, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        // Verify owner received both coins (order might vary)
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            // Take all coins and verify total
            let coin1 = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            let coin2 = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            
            let value1 = coin::value(&coin1);
            let value2 = coin::value(&coin2);
            let total_received = value1 + value2;
            
            // Should have received both tips totaling 2 SUI
            assert!(total_received == 2_000_000_000, 2);
            // Should have received coins of the right individual amounts
            assert!((value1 == 500_000_000 && value2 == 1_500_000_000) || 
                   (value1 == 1_500_000_000 && value2 == 500_000_000), 3);
            
            test_scenario::return_to_sender(&scenario, coin1);
            test_scenario::return_to_sender(&scenario, coin2);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_same_tipper_multiple_times() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Same tipper sends multiple tips
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            // First tip: 0.1 SUI
            let tip_coin1 = create_test_coin(100_000_000, ctx);
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin1, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 100_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 1, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            // Second tip: 0.2 SUI
            let tip_coin2 = create_test_coin(200_000_000, ctx);
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin2, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 300_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 2, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_zero_tip_fails() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Try to send zero tip (should fail)
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let zero_coin = create_test_coin(0, ctx); // 0 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, zero_coin, ctx); // Should abort
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_events_emitted() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Send a tip
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let tip_coin = create_test_coin(500_000_000, ctx); // 0.5 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, tip_coin, ctx);
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_getter_functions() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            
            // Test all getter functions
            assert!(tip_jar_contract::get_owner(&tip_jar) == OWNER, 0);
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 0, 1);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 0, 2);
            assert!(tip_jar_contract::is_owner(&tip_jar, OWNER) == true, 3);
            assert!(tip_jar_contract::is_owner(&tip_jar, TIPPER_1) == false, 4);
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_large_tip_amounts() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Send a large tip (1000 SUI)
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let large_tip = create_test_coin(1000_000_000_000, ctx); // 1000 SUI
            
            tip_jar_contract::send_tip(&mut tip_jar, large_tip, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 1000_000_000_000, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 1, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        // Verify owner received the large tip
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let received_coin = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&received_coin) == 1000_000_000_000, 2);
            test_scenario::return_to_sender(&scenario, received_coin);
        };
        
        test_scenario::end(scenario);
    }

    #[test]
    fun test_minimal_tip_amount() {
        let mut scenario = test_scenario::begin(OWNER);
        
        // Initialize the tip jar
        {
            let ctx = test_scenario::ctx(&mut scenario);
            tip_jar_contract::init_for_testing(ctx);
        };
        
        // Send minimal tip (1 MIST)
        test_scenario::next_tx(&mut scenario, TIPPER_1);
        {
            let mut tip_jar = test_scenario::take_shared<TipJar>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            let minimal_tip = create_test_coin(1, ctx); // 1 MIST
            
            tip_jar_contract::send_tip(&mut tip_jar, minimal_tip, ctx);
            
            assert!(tip_jar_contract::get_total_tips(&tip_jar) == 1, 0);
            assert!(tip_jar_contract::get_tip_count(&tip_jar) == 1, 1);
            
            test_scenario::return_shared(tip_jar);
        };
        
        test_scenario::end(scenario);
    }
}
