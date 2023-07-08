// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Atomic.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";

contract AtomicTest is Test {
    using ECDSA for bytes32;
    Atomic public atomic;

    function setUp() public {
        atomic = new Atomic();
    }

    function testProposeAndSettle() public {
        Atomic.SwapInfo memory info;

        uint256 privateKeyA = 0xa11ce;
        uint256 privateKeyB = 0xabc123;
        address userA = vm.addr(privateKeyA);
        address userB = vm.addr(privateKeyB);
        vm.deal(userA, 1000);
        vm.deal(userB, 1000);

        info.from = userA;
        info.to = userB;
        info.amount = 100;
        info.duration = 1000;
        info.step = 1;
        
        vm.startPrank(userA);
        uint256 id = atomic.propose{value: info.amount}(info);
        Atomic.SwapProof memory proof;
        proof.from = info.from;
        proof.to = info.to;
        proof.amount = info.amount;
        bytes32 hash = keccak256(abi.encode(proof)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyA, hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        vm.stopPrank();

        vm.startPrank(userB);
        atomic.settle(id, proof, signature);
        vm.stopPrank();
    }
}
