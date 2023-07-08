// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Atomic.sol";

contract AtomicTest is Test {
    Atomic public atomic;

    function setUp() public {
        atomic = new Atomic();
    }

    function testProposeAndSettle() public {
        Atomic.SwapInfo memory info;
        info.from = address(this);
        info.to = address(0x1);
        info.amount = 100;
        info.duration = 1000;
        info.step = 1;

        atomic.propose{value: info.amount}(info);
        // call atomic propose with msg.value = amount

        Atomic.SwapProof memory proof;
        proof.from = info.from;
        proof.to = info.to;
        proof.amount = info.amount;
    }
}
