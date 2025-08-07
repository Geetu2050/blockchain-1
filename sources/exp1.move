module geetu_addr::NFTLottery {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use std::vector;

    /// Struct representing an NFT lottery system
    struct Lottery has store, key {
        participants: vector<address>,    // List of participants
        ticket_price: u64,               // Price per lottery ticket
        total_pool: u64,                 // Total funds collected
        nft_collection: vector<u64>,     // Available NFT IDs
        is_active: bool,                 // Lottery status
        owner: address,                  // Lottery owner
    }

    /// Error codes
    const E_LOTTERY_NOT_ACTIVE: u64 = 1;
    const E_INSUFFICIENT_PAYMENT: u64 = 2;
    const E_NO_PARTICIPANTS: u64 = 3;
    const E_NOT_OWNER: u64 = 4;

    /// Function to create a new NFT lottery
    public fun create_lottery(
        owner: &signer, 
        ticket_price: u64, 
        nft_ids: vector<u64>
    ) {
        let owner_addr = signer::address_of(owner);
        let lottery = Lottery {
            participants: vector::empty<address>(),
            ticket_price,
            total_pool: 0,
            nft_collection: nft_ids,
            is_active: true,
            owner: owner_addr,
        };
        move_to(owner, lottery);
    }

    /// Function for users to buy lottery tickets
    public fun buy_ticket(
        participant: &signer, 
        lottery_owner: address
    ) acquires Lottery {
        let lottery = borrow_global_mut<Lottery>(lottery_owner);
        assert!(lottery.is_active, E_LOTTERY_NOT_ACTIVE);
        
        let participant_addr = signer::address_of(participant);
        let payment = coin::withdraw<AptosCoin>(participant, lottery.ticket_price);
        coin::deposit<AptosCoin>(lottery_owner, payment);
        
        vector::push_back(&mut lottery.participants, participant_addr);
        lottery.total_pool = lottery.total_pool + lottery.ticket_price;
    }
}