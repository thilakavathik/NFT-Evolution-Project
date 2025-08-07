module MyModule::NFTEvolution {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    struct EvolvableNFT has store, key {
        name: vector<u8>,        // Name of the NFT
        level: u64,              // Current evolution level
        evolution_points: u64,   // Points needed for next evolution
        max_level: u64,          // Maximum evolution level possible
    }
    

    struct EvolutionConfig has store, key {
        base_cost: u64,          // Base cost for evolution in AptosCoin
        cost_multiplier: u64,    // Multiplier for each level
    }
    
    
    public fun create_nft(creator: &signer, name: vector<u8>, max_level: u64) {
        let nft = EvolvableNFT {
            name,
            level: 1,
            evolution_points: 0,
            max_level,
        };
        
        
        let config = EvolutionConfig {
            base_cost: 100,      // 100 APT base cost
            cost_multiplier: 2,  // Cost doubles each level
        };
        
        move_to(creator, nft);
        move_to(creator, config);
    }
    
    /// Function to evolve NFT by paying tokens
    public fun evolve_nft(owner: &signer, nft_owner: address, payment: u64) acquires EvolvableNFT, EvolutionConfig {
        let nft = borrow_global_mut<EvolvableNFT>(nft_owner);
        let config = borrow_global<EvolutionConfig>(nft_owner);
        
        // Check if NFT can still evolve
        assert!(nft.level < nft.max_level, 1); // Error: Max level reached
        
        // Calculate required cost for next level
        let required_cost = config.base_cost * (config.cost_multiplier * nft.level);
        assert!(payment >= required_cost, 2); // Error: Insufficient payment
        
        // Transfer payment to NFT owner
        let contribution = coin::withdraw<AptosCoin>(owner, payment);
        coin::deposit<AptosCoin>(nft_owner, contribution);
        
        // Evolve the NFT
        nft.level = nft.level + 1;
        nft.evolution_points = nft.evolution_points + payment;
    }
}
