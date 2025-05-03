// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

enum ElementType {
    None,
    Info,
    Value,
    Unique,
    Object,
    List,
    Table,
    Perm,
    Json,
    Wasm,
    Image,
    Model
}

library ElementTypeLib {
    struct RelationRef {
        uint16 rev;
        uint48 rel;
    }

    /// @notice Reference to a fungible token value instance
    struct ElementValueRef {
        uint16 rev; // Token revision
        uint48 tok; // Token ID
        uint192 amount; // Quantity held or used
    }

    /// @notice Reference to a unique token instance
    struct ElementUniqueRef {
        uint16 rev; // Token revision
        uint48 tok; // Token ID
        uint64 id; // Unique object ID
        uint128 amount; // Optional amount (e.g. for partial NFTs)
    }
}
