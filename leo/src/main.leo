program atomic.aleo {
    struct Signature {
        challenge: scalar,
        response: scalar,
        pk_sig: group,
        pr_sig: group,
        sk_prf: scalar,
    }

    struct Message {
        m0: field,
        m1: field,
        m2: field,
        m3: field,
        m4: field,
        m5: field,
        m6: field,
        m7: field,
    }

    function verify(sig: Signature, addr: address, msg: Message, addr_g: group) -> bool {
        let g_r: group = group::GEN * sig.response + sig.pk_sig * sig.challenge;

        let g_r_hash: scalar = Poseidon8::hash_to_scalar(g_r);
        let pk_sig_hash: scalar = Poseidon8::hash_to_scalar(sig.pk_sig);
        let pr_sig_hash: scalar = Poseidon8::hash_to_scalar(sig.pr_sig);
        let addr_hash: scalar = Poseidon8::hash_to_scalar(addr);
        let msg_hash: scalar = Poseidon8::hash_to_scalar(msg);

        let candidate_challenge: scalar = g_r_hash + pk_sig_hash + pr_sig_hash + addr_hash + msg_hash;

        let g_addr: group = sig.pk_sig + sig.pr_sig + group::GEN * sig.sk_prf;

        return (candidate_challenge == sig.challenge) && (g_addr == addr_g);
    }

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

    struct ProofInfo {
        from: address,
        to: address,
        amount: field, // value between 0 and swapinfo.amount
    }

    record Proof {
        owner: address,
        id: field,
        info: ProofInfo,
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
        public proof: ProofInfo, 
        public signature: Signature,
        public message: Message,
        public addr: address
        ) {

        let g_addr: group = Poseidon8::hash_to_group(addr);
        verify(signature, addr, message, g_addr);
   
        // the hash would be the hash of the from address
        // we should check if the hash correspond to the proof that has been created 
        //assert_eq(hash, BHP256::hash_to_field(SwapProof));

        //BHP256::commit_to_field(hash, proof.amount);

        // fronted -> from.sing(swap_proof)
        // check if the proof is correct
        // contract -> swap_proof.verify_is_signed_by(from)
        
        return () then finalize(self.caller, id, proof);
    }
    
    finalize settle(public caller: address, public id: field, public proof: ProofInfo) {
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
    }
        
}
