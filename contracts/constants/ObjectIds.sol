// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

library IdScheme {
    /// @notice 0~16 are reserved for system objects
    uint64 constant SYSTEM_OBJECT_MAX = 16;

    // ───────────────────────────────────────────────
    // Plain Objects: objects with kind > SYSTEM_MAX
    // ───────────────────────────────────────────────
    uint64 constant PLAIN_OBJECT_UNSPECIFIED = 0;
    uint64 constant PLAIN_OBJECT_MIN = 1;
    uint64 constant PLAIN_OBJECT_USER_MIN = 1;
    uint64 constant PLAIN_OBJECT_MAX = 0xFFFFFFFF_FFFFFFFE; // type(uint64).max - 1
    uint64 constant PLAIN_OBJECT_ANY = 0xFFFFFFFF_FFFFFFFF; // type(uint64).max

    // ───────────────────────────────────────────────
    // Semantic Objects: objects with kind <= SYSTEM_MAX
    // These define kinds, sets, relations — the protocol's semantic layer
    // ───────────────────────────────────────────────
    uint64 constant SEMANTIC_OBJECT_MIN = 1;
    uint64 constant SEMANTIC_OBJECT_SYSTEM_MAX = 16;
    uint64 constant SEMANTIC_OBJECT_USER_MIN = 17;
    uint64 constant SEMANTIC_OBJECT_MAX = 0x0000FFFF_FFFFFFFE; // type(uint48).max - 1
}

library KindIds {
    uint64 constant SET = 1;
    uint64 constant KIND = 2;
    uint64 constant RELATION = 3;
    uint64 constant VALUE = 4;
    uint64 constant UNIQUE = 5;
    uint64 constant USER_START = 17;
}

library SetIds {
    uint64 constant SET = 1;
    uint64 constant KIND = 2;
    uint64 constant RELATION = 3;
    uint64 constant VALUE = 4;
    uint64 constant UNIQUE = 5;
    uint64 constant USER_START = 17;
}

library RelationIds {
    uint64 constant USER_START = 17;
}

library ValueIds {
    uint64 constant NATIVE = 0;
    uint64 constant USER_START = 17;
}

library UniqueIds {
    uint64 constant USER_START = 17;
}
