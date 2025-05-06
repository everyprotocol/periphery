// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

/// @notice Struct representing packed minting context
/// @dev Layout (MSB → LSB):
///      [uint64 _reserved | uint64 rangeStart | uint64 rangeEnd | uint32 policy | uint32 tag]
struct MintingContext {
    uint64 _reserved; // bits 192–255 (unused, reserved for future use)
    uint64 rangeStart; // bits 128–191 (inclusive mint range start)
    uint64 rangeEnd; // bits  64–127 (exclusive mint range end)
    uint32 policy; // bits  32–63  (mint policy index)
    uint32 tag; // bits   0–31  (custom tag for metadata or callbacks)
}

/// @title MintingContextLib
/// @notice Utility library for packing and unpacking MintingContext into a 256-bit uint
library MintingContextLib {
    /// @notice Packs a MintingContext struct into a uint256
    /// @param ctx The MintingContext struct
    /// @return packed The packed uint256 value
    function pack(MintingContext memory ctx) internal pure returns (uint256 packed) {
        return (uint256(ctx._reserved) << 192) | (uint256(ctx.rangeStart) << 128) | (uint256(ctx.rangeEnd) << 64)
            | (uint256(ctx.policy) << 32) | uint256(ctx.tag);
    }

    /// @notice Packs context fields into a uint256 (with _reserved = 0)
    /// @param policy Policy index
    /// @param tag Custom tag
    /// @param rangeStart Inclusive ID start
    /// @param rangeEnd Exclusive ID end
    /// @return packed The packed uint256 value
    function pack(uint32 policy, uint32 tag, uint64 rangeStart, uint64 rangeEnd)
        internal
        pure
        returns (uint256 packed)
    {
        return (uint256(rangeStart) << 128) | (uint256(rangeEnd) << 64) | (uint256(policy) << 32) | uint256(tag);
    }

    /// @notice Unpacks a uint256 into a MintingContext struct
    /// @param packed The packed value
    /// @return ctx The unpacked MintingContext struct
    function unpack(uint256 packed) internal pure returns (MintingContext memory ctx) {
        ctx._reserved = uint64(packed >> 192);
        ctx.rangeStart = uint64(packed >> 128);
        ctx.rangeEnd = uint64(packed >> 64);
        ctx.policy = uint32(packed >> 32);
        ctx.tag = uint32(packed);
    }
}
