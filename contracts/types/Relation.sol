// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {TokenType} from "./Token.sol";

/// @notice Represents a constraint on the acceptable number of objects by kind in a relation. A maximum of 16 adjacencies can be specified per relation.
/// @param degs Encodes minimum and maximum degree constraints. minDeg = (degs & 0x8000) >> 15, maxDeg = degs & 0x7FFF
/// @param kind Kind ID of the related object. 0 = any other kind, 0xFFFFFFFFFFFF = total, [1, 2^48 - 2] = specific kind ID
/// @dev Adjacencies are typically specified in a row, with kinds ordered in ascending order.
struct Adjacency {
    uint16 degs;
    uint48 kind;
}

struct SID {
    uint64 set;
    uint64 id;
}

struct Node {
    uint64 data;
    uint32 _reserved;
    uint32 grant;
    uint64 set;
    uint64 id;
}

struct Arc {
    uint64 data;
    uint64 rel;
    uint64 set;
    uint64 id;
}

/// @notice Defines who is authorized to initiate a relation
enum RelationInitiator {
    Owner, // The owner of the object
    Holder, // A holder of a specific token (Value, Unique, or Object)
    Preset, // A specified address
    Eligible, // An address that passes a verifiction
    Anyone // Any address
}

/// @notice Describes a granted permission to initiate a relation
struct RelationGrant {
    uint32 id; // grant id
    uint8 status; // 0 = not exist, 1 = active, 2 = revoked
    RelationInitiator initiator; // The type of authorization
    uint16 reserved; // Reserved for alignment and future use
    uint64 rel; // Optional filter: applies to relatios with a specific relation id (0 = no restriction)
    uint64 kind; // Optional filter: applies to peers with a specific kind id (0 = no restriction)
    uint64 set; // Optional filter: applies to peers with a specific set id (0 = no restriction)
    bytes32 extra; // Encoded RelationInitiatorData, see variants below
}

/// @notice Defines who is allowed to call `unrelate()`
enum RelationTerminator {
    TailOwner, // Only the current tail owner
    HeadOwner, // Only the current head owner
    Either, // Either tail or head owner
    Neither, // Anyone except tail and head owner
    Anyone, // Absolutely anyone
    Nobody // No one (permanent link)
}

/// @notice Defines how ownership of the tail object changes during relate/unrelate
enum RelationOwnerShift {
    // No change
    Retain,
    // Immediate transfers (used during relate or unrelate from HoldPending)
    TransferToTailOwner,
    TransferToHeadOwner,
    TransferToCaller,
    TransferToPreset,
    TransferToBurned,
    TransferToResolved,
    TransferToIntended,
    // Temporary custody by protocol (used during relate)
    HoldForTailOwner,
    HoldForHeadOwner,
    HoldForCaller,
    HoldForPreset,
    HoldForBurned,
    HoldForResolved,
    HoldPending
}

/// @notice Defines relation lifecycle rules: who can relate/unrelate and how ownership shifts
struct RelationRule {
    uint8 version; // Version of the rule format
    RelationOwnerShift relateShift; // Ownership change after relate
    RelationTerminator terminator; // Defines who is allowed to unrelate
    RelationOwnerShift unrelateShift; // Ownership change after unrelate
    uint64 unrelateDelay; // delay before unrelate is allowed (0 = immediate)
    bytes20 extra; // Optional: preset address or contract address to resolve beneficiaries
}

library RelationRuleLib {
    function pack(RelationRule memory r) internal pure returns (bytes32) {
        return bytes32(
            (uint256(uint8(r.version))) | (uint256(uint8(r.relateShift)) << 8) | (uint256(uint8(r.terminator)) << 16)
                | (uint256(uint8(r.unrelateShift)) << 24) | (uint256(r.unrelateDelay) << 32)
                | (uint256(uint160(r.extra)) << 96)
        );
    }

    function unpack(bytes32 b) internal pure returns (RelationRule memory r) {
        uint256 x = uint256(b);
        r.version = uint8(x);
        r.relateShift = RelationOwnerShift(uint8(x >> 8));
        r.terminator = RelationTerminator(uint8(x >> 16));
        r.unrelateShift = RelationOwnerShift(uint8(x >> 24));
        r.unrelateDelay = uint64(x >> 32);
        r.extra = bytes20(uint160(x >> 96));
    }
}

library AdjacencyLib {
    /// Pack one Adjacency into 64 bits: [degs:16 | kind:48]
    function encode(Adjacency memory a) private pure returns (uint64) {
        return (uint64(a.degs) << 48) | uint64(a.kind);
    }

    /// @notice Packs up to 4 adjacencies (starting at `offset`) into a bytes32.
    /// Missing slots are treated as zero.
    function packQuad(Adjacency[] memory adjs, uint256 offset) internal pure returns (bytes32 out) {
        uint256 x;
        if (offset < adjs.length) x |= uint256(encode(adjs[offset])) << 192;
        if (offset + 1 < adjs.length) x |= uint256(encode(adjs[offset + 1])) << 128;
        if (offset + 2 < adjs.length) x |= uint256(encode(adjs[offset + 2])) << 64;
        if (offset + 3 < adjs.length) x |= uint256(encode(adjs[offset + 3]));
        out = bytes32(x);
    }
}

library RelationLib {
    /// @notice Data for Delegate-based authorization
    struct RelationInitiatorDataPreset {
        uint96 padding;
        address delegateAddr; // Authorized address allowed to initiate the relation
    }

    /// @notice Data for Verified-based authorization
    struct RelationInitiatorDataEligible {
        uint96 padding;
        address contractAddr; // Address of the rule-verifying contract
    }

    /// @notice Data for Holder-based authorization
    struct RelationInitiatorDataHolder {
        TokenType tokenType; // Value, Unique, or Object
        uint8 padding;
        uint48 tokenSet; // The set ID of the token
        uint64 tokenId; // The token ID of uniques or objects, 0 for values
        uint128 tokenAmount; // The requried amount of values, 1 for uniques or objects
    }
}
