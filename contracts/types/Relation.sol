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
    Preset, // A specified address
    ValueHolder, // A holder of a value token
    UniqueHolder, // A holder of a unique token
    ObjectHolder, // A holder of an object token
    Eligible, // An address that passes a verifiction
    Anyone // Any address

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

library RelationLib {
    /// @notice Data for Holder-based authorization
    struct RelationInitiatorDataHolder {
        uint64 set; // The set ID for objects, 0 for values/uniques
        uint64 id; // The id/index for uniques/objects, 0 for values
        uint128 amount; // The requried amount for values, 1 for uniques/objects
    }

    /// @notice Pack a preset delegate address into bytes32
    function packPresetData(address delegate) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(delegate)));
    }

    /// @notice Pack an eligible contract address into bytes32
    function packEligibleData(address contract_) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(contract_)));
    }

    /// @notice Pack a value token holder spec (value index + amount) into bytes32
    function packValueHolderData(uint64 index, uint128 amount) internal pure returns (bytes32) {
        return bytes32((uint256(index) << 128) | uint256(amount));
    }

    /// @notice Pack a unique token holder spec (unique index + amount=1) into bytes32
    function packUniqueHolderData(uint64 index, uint128 amount) internal pure returns (bytes32) {
        return packValueHolderData(index, amount);
    }

    /// @notice Pack an object token holder spec (set + id + amount=1) into bytes32
    function packObjectHolderData(uint64 set, uint64 id) internal pure returns (bytes32) {
        return bytes32((uint256(set) << 192) | (uint256(id) << 128) | uint256(1));
    }
}
