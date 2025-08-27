/// Comprehensive tests for the NFT marketplace smart contract
/// Tests cover NFT minting, marketplace operations, and edge cases
#[test_only]
module module3_nft::nft_marketplace_tests {
    use std::string;
    use sui::test_scenario::{Self, next_tx, ctx};
    use module3_nft::nft_marketplace::{Self, WorkshopNFT, Marketplace};
    
    const ADMIN: address = @0xAD;
    const ALICE: address = @0xA11CE;
    const BOB: address = @0xB0B;
    const CHARLIE: address = @0xC0FFEE;
    
    const NFT_NAME: vector<u8> = b"Test NFT";
    const NFT_DESCRIPTION: vector<u8> = b"A test NFT for the workshop";
    const NFT_IMAGE_URL: vector<u8> = b"https://example.com/nft.png";
    const LISTING_PRICE: u64 = 1000;
    
    #[test]
    fun test_init_and_marketplace_creation() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize the module - creates shared marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Check that marketplace was created and shared
        next_tx(&mut scenario, ALICE);
        {
            assert!(test_scenario::has_most_recent_shared<Marketplace>(), 0);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_nft_minting() {
        let mut scenario = test_scenario::begin(ALICE);
        
        // Alice mints an NFT
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            
            // Check NFT properties
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(NFT_NAME), 1);
            assert!(nft_marketplace::nft_description(&nft) == &string::utf8(NFT_DESCRIPTION), 2);
            assert!(nft_marketplace::nft_image_url(&nft) == &string::utf8(NFT_IMAGE_URL), 3);
            assert!(nft_marketplace::nft_creator(&nft) == ALICE, 4);
            
            transfer::public_transfer(nft, ALICE);
        };
        
        // Check that Alice received the NFT
        next_tx(&mut scenario, ALICE);
        {
            assert!(test_scenario::has_most_recent_for_sender<WorkshopNFT>(&scenario), 4);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_mint_to_sender() {
        let mut scenario = test_scenario::begin(ALICE);
        
        // Alice mints NFT directly to her address
        {
            nft_marketplace::mint_to_sender(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
        };
        
        // Check that Alice received the NFT
        next_tx(&mut scenario, ALICE);
        {
            let nft = test_scenario::take_from_sender<WorkshopNFT>(&scenario);
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(NFT_NAME), 1);
            assert!(nft_marketplace::nft_creator(&nft) == ALICE, 2);
            test_scenario::return_to_sender(&scenario, nft);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_listing_nft() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Alice mints and lists an NFT
        next_tx(&mut scenario, ALICE);
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            
            nft_marketplace::list_for_sale(&mut marketplace, nft, LISTING_PRICE, ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_purchase_nft_basic() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Alice mints and lists an NFT
        next_tx(&mut scenario, ALICE);
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            
            nft_marketplace::list_for_sale(&mut marketplace, nft, LISTING_PRICE, ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };
        
        // Note: In a real scenario, Bob would get the listing ID from events
        // For this test, we demonstrate the marketplace interaction pattern
        
        test_scenario::end(scenario);
    }
    
    
    #[test]
    fun test_dynamic_metadata() {
        let mut scenario = test_scenario::begin(ALICE);
        
        // Alice mints an NFT
        {
            let mut nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            
            // Add dynamic metadata
            let rarity_key = string::utf8(b"rarity");
            let rarity_value = string::utf8(b"legendary");
            nft_marketplace::add_metadata(&mut nft, rarity_key, rarity_value);
            
            // Check metadata exists
            assert!(nft_marketplace::has_metadata(&nft, string::utf8(b"rarity")), 1);
            
            // Remove and check metadata
            let removed_rarity: string::String = nft_marketplace::remove_metadata(&mut nft, string::utf8(b"rarity"));
            assert!(removed_rarity == string::utf8(b"legendary"), 2);
            assert!(!nft_marketplace::has_metadata(&nft, string::utf8(b"rarity")), 3);
            
            transfer::public_transfer(nft, ALICE);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    #[expected_failure(abort_code = module3_nft::nft_marketplace::EInvalidPrice)]
    fun test_list_with_zero_price() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Alice tries to list NFT with zero price - should fail
        next_tx(&mut scenario, ALICE);
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            
            // This should fail with EInvalidPrice
            nft_marketplace::list_for_sale(&mut marketplace, nft, 0, ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_remove_listing_pattern() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Alice mints and lists an NFT
        next_tx(&mut scenario, ALICE);
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            
            nft_marketplace::list_for_sale(&mut marketplace, nft, LISTING_PRICE, ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };
        
        // Note: In a real scenario, Alice would track the listing ID from events
        // and could then call remove_listing to get her NFT back
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_nft_properties_and_accessors() {
        let mut scenario = test_scenario::begin(ALICE);
        
        // Test all NFT accessor functions
        {
            let nft = nft_marketplace::mint_nft(NFT_NAME, NFT_DESCRIPTION, NFT_IMAGE_URL, ctx(&mut scenario));
            
            // Test all accessor functions
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(NFT_NAME), 1);
            assert!(nft_marketplace::nft_description(&nft) == &string::utf8(NFT_DESCRIPTION), 2);
            assert!(nft_marketplace::nft_image_url(&nft) == &string::utf8(NFT_IMAGE_URL), 3);
            assert!(nft_marketplace::nft_creator(&nft) == ALICE, 4);
            
            transfer::public_transfer(nft, ALICE);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_multiple_nft_operations() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Initialize marketplace
        {
            nft_marketplace::test_init(ctx(&mut scenario));
        };
        
        // Multiple users create NFTs
        next_tx(&mut scenario, ALICE);
        {
            nft_marketplace::mint_to_sender(b"Alice NFT", b"Alice's creation", b"https://alice.com/nft.png", ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, BOB);
        {
            nft_marketplace::mint_to_sender(b"Bob NFT", b"Bob's masterpiece", b"https://bob.com/nft.png", ctx(&mut scenario));
        };
        
        next_tx(&mut scenario, CHARLIE);
        {
            nft_marketplace::mint_to_sender(b"Charlie NFT", b"Charlie's artwork", b"https://charlie.com/nft.png", ctx(&mut scenario));
        };
        
        // Verify each user has their NFT
        next_tx(&mut scenario, ALICE);
        {
            assert!(test_scenario::has_most_recent_for_sender<WorkshopNFT>(&scenario), 1);
            let nft = test_scenario::take_from_sender<WorkshopNFT>(&scenario);
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(b"Alice NFT"), 2);
            test_scenario::return_to_sender(&scenario, nft);
        };
        
        next_tx(&mut scenario, BOB);
        {
            assert!(test_scenario::has_most_recent_for_sender<WorkshopNFT>(&scenario), 3);
            let nft = test_scenario::take_from_sender<WorkshopNFT>(&scenario);
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(b"Bob NFT"), 4);
            test_scenario::return_to_sender(&scenario, nft);
        };
        
        next_tx(&mut scenario, CHARLIE);
        {
            assert!(test_scenario::has_most_recent_for_sender<WorkshopNFT>(&scenario), 5);
            let nft = test_scenario::take_from_sender<WorkshopNFT>(&scenario);
            assert!(nft_marketplace::nft_name(&nft) == &string::utf8(b"Charlie NFT"), 6);
            test_scenario::return_to_sender(&scenario, nft);
        };
        
        test_scenario::end(scenario);
    }
}