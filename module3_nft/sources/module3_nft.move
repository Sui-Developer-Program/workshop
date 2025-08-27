/// Module: module3_nft  
/// NFT Marketplace implementation demonstrating Sui Move concepts from Module 3
/// Key concepts: NFT creation, shared objects, marketplace logic, dynamic fields
module module3_nft::nft_marketplace {
    use std::string::{Self, String};
    use sui::event;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::display;
    use sui::package;
    
    /// One-time witness for publisher creation
    public struct NFT_MARKETPLACE has drop {}
    
    /// Errors
    const ENotOwner: u64 = 1;
    const EInsufficientPayment: u64 = 2;
    const ENotForSale: u64 = 3;
    const EInvalidPrice: u64 = 4;
    
    /// NFT struct representing a digital collectible
    /// Contains metadata like name, description, and image URL as specified in Module 3 exercises
    public struct WorkshopNFT has key, store {
        id: UID,
        name: String,
        description: String,
        image_url: String,
        creator: address,
        // Dynamic fields can be added at runtime for additional metadata
    }
    
    /// Listing struct for NFTs offered for sale
    /// This represents individual listings in the marketplace
    public struct Listing has key, store {
        id: UID,
        nft: WorkshopNFT,
        price: u64,
        seller: address,
    }
    
    /// Shared marketplace object that stores all listings
    /// This is a shared object accessible by everyone as shown in presentations
    public struct Marketplace has key {
        id: UID,
        // Listings are stored as dynamic object fields for efficient access
        // Key: listing ID, Value: Listing object
    }
    
    /// Events for tracking marketplace activity
    public struct NFTMinted has copy, drop {
        nft_id: ID,
        name: String,
        creator: address,
    }
    
    public struct NFTListed has copy, drop {
        nft_id: ID,
        listing_id: ID,
        price: u64,
        seller: address,
    }
    
    public struct NFTPurchased has copy, drop {
        nft_id: ID,
        listing_id: ID,
        price: u64,
        seller: address,
        buyer: address,
    }
    
    /// Module initializer - creates and shares the marketplace and sets up display
    /// This is called once when the module is published
    fun init(otw: NFT_MARKETPLACE, ctx: &mut TxContext) {
        // Create the marketplace
        let marketplace = Marketplace {
            id: object::new(ctx),
        };
        
        // Create publisher for display
        let publisher = package::claim(otw, ctx);
        
        // Set up display fields for the NFT
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"), 
            string::utf8(b"image_url"),
            string::utf8(b"creator"),
            string::utf8(b"project_url"),
        ];
        
        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{description}"),
            string::utf8(b"{image_url}"),
            string::utf8(b"{creator}"),
            string::utf8(b"https://sui.io/developers"), // Static project URL
        ];
        
        // Create and setup display object
        let mut display = display::new_with_fields<WorkshopNFT>(&publisher, keys, values, ctx);
        display.update_version();
        
        // Transfer objects
        transfer::public_transfer(publisher, ctx.sender());
        transfer::public_transfer(display, ctx.sender());
        transfer::share_object(marketplace);
    }
    
    /// Mint a new NFT - demonstrates NFT creation as specified in Module 3
    /// Anyone can mint an NFT with name, description, and image URL
    public fun mint_nft(
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        ctx: &mut TxContext,
    ): WorkshopNFT {
        let nft = WorkshopNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            image_url: string::utf8(image_url),
            creator: ctx.sender(),
        };
        
        // Emit event for NFT minting
        event::emit(NFTMinted {
            nft_id: object::id(&nft),
            name: nft.name,
            creator: nft.creator,
        });
        
        nft
    }
    
    /// Convenience function to mint and transfer NFT to sender
    public entry fun mint_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        image_url: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let nft = mint_nft(name, description, image_url, ctx);
        transfer::public_transfer(nft, ctx.sender());
    }
    
    /// List an NFT for sale - demonstrates marketplace listing logic
    /// Creates a Listing object and stores it in the shared marketplace
    public entry fun list_for_sale(
        marketplace: &mut Marketplace,
        nft: WorkshopNFT,
        price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(price > 0, EInvalidPrice);
        
        let listing_id = object::new(ctx);
        let nft_id = object::id(&nft);
        
        let listing = Listing {
            id: listing_id,
            nft,
            price,
            seller: ctx.sender(),
        };
        
        // Store the listing as a dynamic object field
        let listing_id_copy = object::uid_to_inner(&listing.id);
        dof::add(&mut marketplace.id, listing_id_copy, listing);
        
        // Emit event for listing
        event::emit(NFTListed {
            nft_id,
            listing_id: listing_id_copy,
            price,
            seller: ctx.sender(),
        });
    }
    
    /// Purchase an NFT from the marketplace - demonstrates purchase logic
    /// Handles payment and transfers ownership as specified in Module 3
    public entry fun purchase_nft(
        marketplace: &mut Marketplace,
        listing_id: ID,
        mut payment: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Check if listing exists
        assert!(dof::exists_(&marketplace.id, listing_id), ENotForSale);
        
        // Remove the listing from marketplace
        let listing: Listing = dof::remove(&mut marketplace.id, listing_id);
        
        let Listing { id, nft, price, seller } = listing;
        
        // Check payment is sufficient
        let payment_amount = coin::value(&payment);
        assert!(payment_amount >= price, EInsufficientPayment);
        
        // Calculate any change needed
        if (payment_amount > price) {
            let change = coin::split(&mut payment, payment_amount - price, ctx);
            transfer::public_transfer(change, ctx.sender());
        };
        
        // Transfer payment to seller
        transfer::public_transfer(payment, seller);
        
        // Transfer NFT to buyer
        let buyer = ctx.sender();
        let nft_id = object::id(&nft);
        transfer::public_transfer(nft, buyer);
        
        // Clean up listing ID
        object::delete(id);
        
        // Emit event for purchase
        event::emit(NFTPurchased {
            nft_id,
            listing_id,
            price,
            seller,
            buyer,
        });
    }
    
    /// Remove a listing from the marketplace (seller only)
    /// Returns the NFT to the original seller
    public entry fun remove_listing(
        marketplace: &mut Marketplace,
        listing_id: ID,
        ctx: &mut TxContext,
    ) {
        assert!(dof::exists_(&marketplace.id, listing_id), ENotForSale);
        
        let listing: Listing = dof::remove(&mut marketplace.id, listing_id);
        let Listing { id, nft, price: _, seller } = listing;
        
        // Only seller can remove their listing
        assert!(seller == ctx.sender(), ENotOwner);
        
        // Return NFT to seller
        transfer::public_transfer(nft, seller);
        
        // Clean up listing ID
        object::delete(id);
    }
    
    /// Add dynamic metadata to an NFT - demonstrates dynamic fields as shown in presentations
    /// This allows extending NFT functionality at runtime
    public fun add_metadata<T: store>(
        nft: &mut WorkshopNFT,
        key: String,
        value: T,
    ) {
        df::add(&mut nft.id, key, value);
    }
    
    /// Remove dynamic metadata from an NFT
    public fun remove_metadata<T: store>(
        nft: &mut WorkshopNFT,
        key: String,
    ): T {
        df::remove(&mut nft.id, key)
    }
    
    /// Check if NFT has specific metadata
    public fun has_metadata(
        nft: &WorkshopNFT,
        key: String,
    ): bool {
        df::exists_(&nft.id, key)
    }
    
    /// Accessor functions for NFT properties
    public fun nft_name(nft: &WorkshopNFT): &String {
        &nft.name
    }
    
    public fun nft_description(nft: &WorkshopNFT): &String {
        &nft.description
    }
    
    public fun nft_creator(nft: &WorkshopNFT): address {
        nft.creator
    }
    
    public fun nft_image_url(nft: &WorkshopNFT): &String {
        &nft.image_url
    }
    
    /// Accessor functions for Listing properties
    public fun listing_price(marketplace: &Marketplace, listing_id: ID): u64 {
        let listing: &Listing = dof::borrow(&marketplace.id, listing_id);
        listing.price
    }
    
    public fun listing_seller(marketplace: &Marketplace, listing_id: ID): address {
        let listing: &Listing = dof::borrow(&marketplace.id, listing_id);
        listing.seller
    }
    
    public fun listing_nft_name(marketplace: &Marketplace, listing_id: ID): &String {
        let listing: &Listing = dof::borrow(&marketplace.id, listing_id);
        &listing.nft.name
    }
    
    /// Check if a listing exists in the marketplace
    public fun listing_exists(marketplace: &Marketplace, listing_id: ID): bool {
        dof::exists_(&marketplace.id, listing_id)
    }
    
    /// Test-only function for module initialization
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(NFT_MARKETPLACE {}, ctx);
    }
}