// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {Adjacency, RelationRule} from "../../types/Relation.sol";

/// @title IRelationRegistry
/// @notice Interface for registering and managing relations
interface IRelationRegistry {
    // --- Events ---

    /// @notice Emitted when a new relation is registered
    /// @param id ID of the relation
    /// @param desc Descriptor of the relation
    /// @param code Optional logic contract address
    /// @param data Hash of the associated metadata or logic
    /// @param rule Relation rule defining interaction logic
    /// @param adjs List of admitted tail kinds and degree constraints
    /// @param owner Address of the relation's owner
    event RelationRegistered(
        uint64 id, Descriptor desc, address code, bytes32 data, RelationRule rule, Adjacency[] adjs, address owner
    );

    /// @notice Emitted when a relation is updated
    /// @param id ID of the relation
    /// @param desc Updated descriptor
    /// @param data New data hash
    event RelationUpdated(uint64 id, Descriptor desc, bytes32 data);

    /// @notice Emitted when a relation is updated
    /// @param id ID of the relation
    /// @param desc Updated descriptor
    /// @param adjs List of admitted tail kinds and degree constraints
    /// @param data New data hash
    event RelationUpdated(uint64 id, Descriptor desc, bytes32 data, Adjacency[] adjs);

    /// @notice Emitted when a relation is upgraded (kind/set revision bumped)
    /// @param id ID of the relation
    /// @param desc Descriptor after upgrade
    event RelationUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a relation is touched (revision incremented without content change)
    /// @param id ID of the relation
    /// @param desc Descriptor after touch
    event RelationTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership of a relation is transferred
    /// @param id ID of the relation
    /// @param desc Descriptor after the transfer
    /// @param from Previous owner
    /// @param to New owner
    event RelationTransferred(uint64 id, Descriptor desc, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new relation
    /// @param code Optional logic contract address
    /// @param data Hash of the relation’s associated data
    /// @param rule Rule defining the behavior and constraints of the relation
    /// @param adjs Array of tail kind admissibility and degree limits
    /// @return id New relation ID
    /// @return desc Descriptor after registration
    function relationRegister(address code, bytes32 data, RelationRule memory rule, Adjacency[] memory adjs)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of a relation
    /// @param id Relation ID
    /// @param data New data hash
    /// @return desc Updated descriptor
    function relationUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the data hash and adjacency configuration of a relation
    /// @param id Relation ID
    /// @param data New data hash
    /// @param adjs New array of adjacency rules
    /// @return desc Updated descriptor
    function relationUpdate(uint64 id, bytes32 data, Adjacency[] memory adjs) external returns (Descriptor memory desc);

    /// @notice Upgrades the kind or set revision of a relation
    /// @param id Relation ID
    /// @param kindRev New kind revision (0 = no change)
    /// @param setRev New set revision (0 = no change)
    /// @return desc Descriptor after upgrade
    function relationUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a relation (bumps revision without modifying content)
    /// @param id Relation ID
    /// @return desc Descriptor after touch
    function relationTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a relation to a new address
    /// @param id Relation ID
    /// @param to New owner address
    /// @return from Previous owner address
    function relationTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Resolves and validates a revision number
    /// @param id Relation ID
    /// @param rev0 Requested revision (0 = latest)
    /// @return rev Validated revision (0 if not found)
    function relationRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /// @notice Returns descriptor of a relation at a specific revision
    /// @param id Relation ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the specified revision
    function relationDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Returns descriptor and packed elements at a specific revision
    /// @param id Relation ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the revision
    /// @return elems Elements at the revision
    function relationSnapshot(uint64 id, uint32 rev0)
        external
        view
        returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a relation
    /// @param id Relation ID
    /// @return owner Address of the current owner
    function relationOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the latest descriptor and current owner of a relation
    /// @param id Relation ID
    /// @return desc Latest descriptor
    /// @return owner Current owner
    function relationSota(uint64 id) external view returns (Descriptor memory desc, address owner);

    /// @notice Checks whether all specified relations are active (rev > 0)
    /// @param ids Array of relation IDs
    /// @return active True if all are valid and active
    function relationStatus(uint64[] memory ids) external view returns (bool active);

    /// @notice Returns the rule definition for a relation
    /// @param id Relation ID
    /// @return rule Possession and linkage rule for the relation
    function relationRule(uint64 id) external view returns (RelationRule memory rule);

    /// @notice Checks if a relation admits a specific kind as tail
    /// @param id Relation ID
    /// @param rev Revision to check
    /// @param kind Tail kind ID to evaluate
    /// @return admit Whether the kind is admitted
    /// @return effKind Matched kind (0 = wildcard match)
    /// @return effDegs Degree bounds for the matched kind
    /// @return totalKind Special marker for total-kind (2^48-1 if defined)
    /// @return totalDegs Degree bounds for the total-kind
    function relationAdmit(uint64 id, uint32 rev, uint64 kind)
        external
        view
        returns (bool admit, uint48 effKind, uint16 effDegs, uint48 totalKind, uint16 totalDegs);
}
