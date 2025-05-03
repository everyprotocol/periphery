// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {RelationGrant} from "../../types/Relation.sol";

/// @title IObjectAuthorization
/// @notice Interface for managing relation-based authorization for objects.
/// Grants allow external accounts to initiate or participate in object relations,
/// scoped by direction (from/to), relation ID, kind, and set.
interface IObjectAuthorization {
    // --- Events ---

    /// @notice Emitted when a grant is issued for initiating a relation from an object
    event GrantFrom(uint128 tail, RelationGrant grant);

    /// @notice Emitted when a previously issued grant from an object is revoked
    event RevokeFrom(uint128 tail, uint32 grantId);

    /// @notice Emitted when a grant is issued for participating in a relation to an object
    event GrantTo(uint128 head, RelationGrant grant);

    /// @notice Emitted when a previously issued grant to an object is revoked
    event RevokeTo(uint128 head, uint32 grantId);

    // --- Write Methods ---

    /// @notice Issues a grant allowing relation initiation from a given tail object
    function grantFrom(uint128 tail, RelationGrant memory grant) external;

    /// @notice Revokes a previously granted authorization from a tail object
    function revokeFrom(uint128 tail, uint32 grantId) external;

    /// @notice Issues a grant allowing relation participation to a given head object
    function grantTo(uint128 head, RelationGrant memory grant) external;

    /// @notice Revokes a previously granted authorization to a head object
    function revokeTo(uint128 head, uint32 grantId) external;

    // --- Read Methods ---

    /// @notice Checks if a sender is authorized to initiate a relation from a given tail object
    /// @param grantId The ID of the grant to evaluate
    /// @param sender The address attempting to initiate the relation
    /// @param tail The object acting as tail (source of relation)
    /// @param rel The relation ID being initiated
    /// @param headKind The kind ID of the target object
    /// @param headSet The set ID of the target object
    /// @return True if the sender is authorized, false otherwise
    function allowFrom(uint32 grantId, address sender, uint128 tail, uint64 rel, uint64 headKind, uint64 headSet)
        external
        view
        returns (bool);

    /// @notice Checks if a sender is authorized to accept a relation to a given head object
    /// @param grantId The ID of the grant to evaluate
    /// @param sender The address attempting to link to the head
    /// @param head The object acting as head (target of relation)
    /// @param rel The relation ID being accepted
    /// @param tailKind The kind ID of the source object
    /// @param tailSet The set ID of the source object
    /// @return True if the sender is authorized, false otherwise
    function allowTo(uint32 grantId, address sender, uint128 head, uint64 rel, uint64 tailKind, uint64 tailSet)
        external
        view
        returns (bool);
}
