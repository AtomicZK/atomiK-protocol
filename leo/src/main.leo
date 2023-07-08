// The 'vote.leo' program.
program atomic.aleo {

    // Records
    // Swap { from, to, amount, duration, step, start_time }
    // from -> caller
    // to -> input
    // amount -> input
    // duration -> fixed value
    // step -> fixed value
    // start_time -> now

    struct SwapInfo {
        from: address,
        to: address,
        amount: field,
        duration: u32,
        step: field,
        start_time: u32,
    }

    // Proposal swap records proposal info publicly
    record Swap {
        owner: address,
        id: field,
        info: SwapInfo,
    }

    // Save swap info in public storage.
    mapping swaps: field => SwapInfo;

    mapping starts: field => u32;


    // Propose a new swap
    transition propose(
      public info: SwapInfo
      ) -> Swap {
        // Authenticate proposer.
        assert_eq(self.caller, info.from);

        // Generate a new proposal id.
        let id: field = BHP256::hash_to_field(info);

        // Return a new record for the proposal.
        // Finalize the proposal id.
        return Swap {
            owner: self.caller,
            id,
            info,
        } then finalize(id, info);
    }
    
    // Create a new swap in the "swap" mapping.
    finalize propose(public id: field, info: SwapInfo) {
        Mapping::set(swaps, id, info);
        Mapping::set(starts, id, block.height);
    }

    // settle the transaction 

    struct SwapProof {
        from: address,
        to: address,
        amount: field, // value between 0 and swapinfo.amount
    }

    // Onchain [propose]
    // U1 -> Deposit 1000 token A in Ethereum Contract
    // U2 -> Deposit 1000 token B in Aleo Contract

    // Offchain [loop with n from 1 to swapinfo.amount]
    // U1 -> Send SwapProof { from: U1, to: U2, amount: n } to U2
    // U2 -> Send SwapProof { from: U1, to: U2, amount: n } to U1

    // Onchain [settle]
    // U1 -> Send SwapProof { from: U1, to: U2, amount: n } in Aleo Contract -> U2 get n token A
    // U2 -> Send SwapProof { from: U1, to: U2, amount: n } in Ethereum Contract -> U1 get n token B
    

    transition settle(
        public id: field, 
        public proof: SwapProof, 
        public info: SwapInfo, 
        public hash: field
        ) {


        // 3. transfer tokens to caller

            
        // the hash would be the hash of the from address
        // we should check if the hash correspond to the proof that has been created 
        //assert_eq(hash, BHP256::hash_to_field(SwapProof));

        //BHP256::commit_to_field(hash, proof.amount);

        // fronted -> from.sing(swap_proof)
        // check if the proof is correct
        // contract -> swap_proof.verify_is_signed_by(from)
        
        return () then finalize(self.caller, id, proof);
    }
    
    finalize settle(public caller: address, public id: field, public proof: SwapProof) {
        let info: SwapInfo = Mapping::get(swaps, id);
        // Authenticate proposer.
        if caller == info.from {
            // 1. if caller == from -> verify start_time + durantion < now
            let start_time: u32 = Mapping::get(starts, id);
            assert(start_time + info.duration < block.height); // no error here (just extension)
        } else if caller == info.to {
            // 2. if caller == to -> verify proof is correct
            let hash: field = BHP256::hash_to_field(proof);
            
        } else {
            // throw error
            return;
        }

        // transfer to caller the amount of token
        
        
    }
        
}
