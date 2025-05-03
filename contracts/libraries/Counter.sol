// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Counter48
 * @notice Counter for objects with IDs from 1 to type(uint48).max inclusive
 */
library Counter48 {
    uint48 constant MIN_ID = 1;
    uint48 constant MAX_ID = type(uint48).max - 1;

    struct Counter {
        uint48 value;
    }

    error Overflow();
    error Underflow();
    error InvalidInitial();

    function initialize(Counter storage counter, uint48 initial) internal {
        if (initial < MIN_ID || initial > MAX_ID) revert InvalidInitial();
        counter.value = initial;
    }

    function increase(Counter storage counter) internal returns (uint48 previous) {
        if (counter.value >= MAX_ID) revert Overflow();
        previous = counter.value++;
    }

    function decrease(Counter storage counter) internal returns (uint48 previous) {
        if (counter.value <= MIN_ID) revert Underflow();
        previous = counter.value--;
    }

    function current(Counter storage counter) internal view returns (uint48) {
        return counter.value;
    }
}

/**
 * @title Counter64
 * @notice Counter for objects with IDs from 1 to type(uint64).max inclusive
 */
library Counter64 {
    uint64 constant MIN_ID = 1;
    uint64 constant MAX_ID = type(uint64).max - 1;

    struct Counter {
        uint64 value;
    }

    error Overflow();
    error Underflow();
    error InvalidInitial();

    function initialize(Counter storage counter, uint64 initial) internal {
        if (initial < MIN_ID || initial > MAX_ID) revert InvalidInitial();
        counter.value = initial;
    }

    function increment(Counter storage counter) internal returns (uint64 previous) {
        if (counter.value >= MAX_ID) revert Overflow();
        previous = counter.value++;
    }

    function decrement(Counter storage counter) internal returns (uint64 previous) {
        if (counter.value <= MIN_ID) revert Underflow();
        previous = counter.value--;
    }

    function current(Counter storage counter) internal view returns (uint64) {
        return counter.value;
    }
}
