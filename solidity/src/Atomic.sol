// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract AtomicSwap {
    struct SwapInfo {
        address from;
        address to;
        uint256 amount;
        uint256 duration;
        uint256 step;
        uint256 start_time;
    }

    struct Swap {
        address owner;
        uint256 id;
        SwapInfo info;
    }

    struct SwapProof {
        address from;
        address to;
        uint256 amount;
    }

    mapping(uint256 => SwapInfo) public swaps;
    mapping(uint256 => uint256) public starts;

    function propose(SwapInfo memory info) public returns (Swap memory) {
        require(msg.sender == info.from, "Only the owner can propose");

        uint256 id = uint256(keccak256(abi.encode(info)));

        swaps[id] = info;
        starts[id] = block.timestamp;

        return Swap({owner: msg.sender, id: id, info: info});
    }

    function settle(uint256 id, SwapProof memory proof, SwapInfo memory info, bytes32 hash) public {
        require(hash == keccak256(abi.encode(proof)), "Invalid proof");

        SwapInfo memory swap = swaps[id];

        if(msg.sender == swap.from) {
            require(starts[id] + swap.duration < block.timestamp, "Invalid call timing");
        } else if(msg.sender == swap.to) {
            // add code here to verify proof
        } else {
            revert("Invalid caller");
        }

        // add code here to transfer tokens to caller
    }
}
