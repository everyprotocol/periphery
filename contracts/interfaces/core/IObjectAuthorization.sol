// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {RelationGrant} from "../../types/Relation.sol";

/// @title IObjectAuthorization
/// @notice Handles fine-grained authorization for object relations.
/// @dev Grants control who can initiate (`from`) or accept (`to`) object-to-object relations,
/// scoped by direction, relation ID, kind, and set.
interface IObjectAuthorization {
    // --- Events ---

    /// @notice Emitted when a grant is issued to authorize initiating a relation from a tail object
    /// @param tail Tail object ID (initiator)
    /// @param grant Grant definition
    event GrantFrom(uint128 tail, RelationGrant grant);

    /// @notice Emitted when a grant from a tail object is revoked
    /// @param tail Tail object ID (initiator)
    /// @param grantId ID of the revoked grant
    event RevokeFrom(uint128 tail, uint32 grantId);

    /// @notice Emitted when a grant is issued to authorize accepting a relation to a head object
    /// @param head Head object ID (receiver)
    /// @param grant Grant definition
    event GrantTo(uint128 head, RelationGrant grant);

    /// @notice Emitted when a grant to a head object is revoked
    /// @param head Head object ID (receiver)
    /// @param grantId ID of the revoked grant
    event RevokeTo(uint128 head, uint32 grantId);

    // --- Write Methods ---

    /// @notice Issues a grant to allow initiating relations from a tail object
    /// @param tail Tail object ID
    /// @param grant Grant details
    function grantFrom(uint128 tail, RelationGrant memory grant) external;

    /// @notice Revokes a previously issued `from` grant
    /// @param tail Tail object ID
    /// @param grantId Grant ID to revoke
    function revokeFrom(uint128 tail, uint32 grantId) external;

    /// @notice Issues a grant to allow accepting relations to a head object
    /// @param head Head object ID
    /// @param grant Grant details
    function grantTo(uint128 head, RelationGrant memory grant) external;

    /// @notice Revokes a previously issued `to` grant
    /// @param head Head object ID
    /// @param grantId Grant ID to revoke
    function revokeTo(uint128 head, uint32 grantId) external;

    // --- Read Methods ---

    /// @notice Checks whether a sender is authorized to initiate a relation from a tail object
    /// @param grantId Grant ID to check
    /// @param sender Address attempting the action
    /// @param tail Tail object ID
    /// @param rel Relation ID
    /// @param headKind Kind ID of the target (head) object
    /// @param headSet Set ID of the target (head) object
    /// @return allowed True if authorized
    function allowFrom(uint32 grantId, address sender, uint128 tail, uint64 rel, uint64 headKind, uint64 headSet)
        external
        view
        returns (bool allowed);

    /// @notice Checks whether a sender is authorized to accept a relation to a head object
    /// @param grantId Grant ID to check
    /// @param sender Address attempting the action
    /// @param head Head object ID
    /// @param rel Relation ID
    /// @param tailKind Kind ID of the source (tail) object
    /// @param tailSet Set ID of the source (tail) object
    /// @return allowed True if authorized
    function allowTo(uint32 grantId, address sender, uint128 head, uint64 rel, uint64 tailKind, uint64 tailSet)
        external
        view
        returns (bool allowed);
}
