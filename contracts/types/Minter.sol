// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

/// @notice Defines the access and payment rules for minting objects
struct MintPolicy {
    // -- Protocol-controlled fields --
    uint32 index; // Unique policy index (assigned by system)
    MintPolicyStatus status;
    // -- User-configured fields --
    MintPermissionType perm; // Type of permission required
    uint16 limit; // Max mints per address
    uint32 tag; // Arbitrary user tag passed back during callbacks
    address recipient; // Where funds are sent (e.g., creator)
    address currency; // Payment token (zero = native)
    uint96 price; // Price per mint
    uint64 idStart; // Start object ID (inclusive)
    uint64 idEnd; // End object ID (exclusive)
    uint64 saleStart; // Mint start timestamp
    uint64 saleEnd; // Mint end timestamp (exclusive)
    bytes32 data; // Permission data (e.g. Merkle root)
}

/// @notice Indicates the current status of a mint policy
enum MintPolicyStatus {
    None, // Uninitialized
    Enabled, // Active
    Disabled // Exists but cannot be used
}

///@notice Access modes used to restrict who can mint
enum MintPermissionType {
    Public, // Open to all, no proof required
    Allowlist, // Merkle proof of address required
    AllowTable // Merkle proof of (address, price, limit) required
}

/**
 * @notice Encoded permission data tied to a policy
 * @dev For Public: must be `bytes32(0)`
 *      For Allowlist / AllowTable: must be a Merkle root
 */
type MintPermissionData is bytes32;

/**
 * @title MintPermissionLib
 * @notice Encodes, decodes, and verifies mint auth data for each permission type.
 */
library MintPermissionLib {
    // === Allowlist ===

    function allowList_Encode(bytes32[] memory proof) internal pure returns (bytes memory auth) {
        return abi.encode(proof);
    }

    function allowList_Decode(bytes memory auth) internal pure returns (bytes32[] memory proof) {
        (proof) = abi.decode(auth, (bytes32[]));
    }

    function allowList_Leaf(address user) internal pure returns (bytes32) {
        return keccak256(abi.encode(user));
    }

    // === AllowTable ===

    function allowTable_Encode(uint96 price, uint16 limit, bytes32[] memory proof)
        internal
        pure
        returns (bytes memory auth)
    {
        return abi.encode(price, limit, proof);
    }

    function allowTable_Decode(bytes memory auth)
        internal
        pure
        returns (uint96 price, uint16 limit, bytes32[] memory proof)
    {
        (price, limit, proof) = abi.decode(auth, (uint96, uint16, bytes32[]));
    }

    function allowTable_Leaf(address user, uint96 price, uint16 limit) internal pure returns (bytes32) {
        return keccak256(abi.encode(user, price, limit));
    }
}

/// @notice Struct representing packed minting context
/// @dev Layout (MSB → LSB):
///      [uint64 _reserved | uint64 idStart | uint64 idEnd | uint32 policy | uint32 tag]
struct MintContext {
    uint64 _reserved; // bits 192–255 (reserved for future use)
    uint64 idStart; // bits 128–191 (inclusive object ID start)
    uint64 idEnd; // bits  64–127 (exclusive object ID end)
    uint32 policy; // bits  32–63  (policy index)
    uint32 tag; // bits   0–31  (user-defined tag for callback)
}

/// @title MintContextLib
/// @notice Utility library for packing/unpacking MintContext into a uint256 word
library MintContextLib {
    /// @notice Packs a MintContext struct into a single uint256
    /// @param ctx The MintContext struct
    /// @return packed The packed uint256 representation
    function pack(MintContext memory ctx) internal pure returns (uint256 packed) {
        return (uint256(ctx._reserved) << 192) | (uint256(ctx.idStart) << 128) | (uint256(ctx.idEnd) << 64)
            | (uint256(ctx.policy) << 32) | uint256(ctx.tag);
    }

    /// @notice Packs individual context fields into a uint256 (with _reserved = 0)
    /// @param policy Policy index
    /// @param tag Custom user tag
    /// @param idStart Inclusive object ID start
    /// @param idEnd Exclusive object ID end
    /// @return packed The packed uint256 representation
    function pack(uint32 policy, uint32 tag, uint64 idStart, uint64 idEnd) internal pure returns (uint256 packed) {
        return (uint256(idStart) << 128) | (uint256(idEnd) << 64) | (uint256(policy) << 32) | uint256(tag);
    }

    /// @notice Unpacks a packed uint256 into a MintContext struct
    /// @param packed The packed uint256
    /// @return ctx The unpacked MintContext struct
    function unpack(uint256 packed) internal pure returns (MintContext memory ctx) {
        ctx._reserved = uint64(packed >> 192);
        ctx.idStart = uint64(packed >> 128);
        ctx.idEnd = uint64(packed >> 64);
        ctx.policy = uint32(packed >> 32);
        ctx.tag = uint32(packed);
    }
}
