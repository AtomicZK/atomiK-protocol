// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Signature.sol";

contract Atomic is VerifySignature {
    struct SwapInfo {
        address from;
        address to;
        uint256 amount;
        uint256 duration;
        uint256 step;
    }

    struct SwapProof {
        address from;
        address to;
        uint256 amount;
    }

    mapping(uint256 => SwapInfo) public swaps;
    mapping(uint256 => uint256) public starts;

    function propose(SwapInfo memory info) public payable {
        require(msg.sender == info.from, "Only the owner can propose");
        require(msg.value == info.amount, "Invalid amount");

        uint256 id = uint256(keccak256(abi.encode(info)));

        swaps[id] = info;
        starts[id] = block.timestamp;
    }

    function settle(uint256 id, SwapProof memory proof, bytes memory signature) public {
        SwapInfo memory swap = swaps[id];

        require(swap.amount > proof.amount, "Invalid amount");

        if(msg.sender == swap.from) {
            require(starts[id] + swap.duration < block.timestamp, "Invalid call timing");
        } else if(msg.sender == swap.to) {
            // add code here to verify proof
            bytes32 hash = keccak256(abi.encode(proof));
            address signer = recoverSigner(hash, signature);
            require(signer == swap.from, "Invalid signature");

        } else {
            revert("Invalid caller");
        }
        //transfert the balance of the msg.sender to the swap.to 
        payable(msg.sender).transfer(swap.amount);
    }
}