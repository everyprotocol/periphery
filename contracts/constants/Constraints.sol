// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

library Constraints {
    // ──────────────────────────────
    // Kind-level constraints
    // ──────────────────────────────
    uint256 constant MAX_KIND_ELEMENTS = 16;
    uint256 constant MAX_KIND_RELATIONS = 16;

    // ──────────────────────────────
    // Relation-level constraints
    // ──────────────────────────────
    uint256 constant MAX_RELATION_ADJACENCIES = 16;
}
