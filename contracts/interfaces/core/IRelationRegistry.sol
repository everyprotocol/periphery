// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {Adjacency, RelationRule} from "../../types/Relation.sol";

/**
 * @title IRelationRegistry
 * @notice Manages relation registration and updates
 */
interface IRelationRegistry {
    // --- Events ---

    /// @notice Emitted when a new relation is registered
    /// @param id ID of the relation
    /// @param desc Descriptor of the relation
    /// @param code Address of the relation logic contract (if any)
    /// @param data Hash of the associated matter
    /// @param rule Rule defining possession logic
    /// @param adjs Adjacency definitions
    /// @param owner Owner of the relation
    event RelationRegistered(
        uint64 id, Descriptor desc, address code, bytes32 data, RelationRule rule, Adjacency[] adjs, address owner
    );

    /// @notice Emitted when a relation is updated
    /// @param id ID of the relation
    /// @param desc Updated descriptor
    /// @param data New data hash
    event RelationUpdated(uint64 id, Descriptor desc, bytes32 data);

    /// @notice Emitted when a relation is upgraded
    /// @param id ID of the relation
    /// @param desc Descriptor after upgrade
    event RelationUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a relation is touched (revision bumped without change)
    /// @param id ID of the relation
    /// @param desc Descriptor after touch
    event RelationTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership is transferred
    /// @param id ID of the relation
    /// @param from Previous owner
    /// @param to New owner
    event RelationTransferred(uint64 id, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new relation
    /// @param code Optional logic contract address
    /// @param data Hash of the relation’s matter
    /// @param rule Possession rule definition
    /// @param adjs List of adjacency definitions
    /// @return id New relation ID
    /// @return desc Descriptor of the new relation
    function relationRegister(address code, bytes32 data, RelationRule memory rule, Adjacency[] memory adjs)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates a relation’s data hash
    /// @param id ID of the relation
    /// @param data New data hash
    /// @return desc Updated descriptor
    function relationUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates data hash and adjacencies of a relation
    /// @param id ID of the relation
    /// @param data New data hash
    /// @param adjs New adjacency list
    /// @return desc Updated descriptor
    function relationUpdate(uint64 id, bytes32 data, Adjacency[] memory adjs)
        external
        returns (Descriptor memory desc);

    /// @notice Upgrades kind or set revision of a relation
    /// @param id ID of the relation
    /// @param kindRev New kind revision (0 = no change)
    /// @param setRev New set revision (0 = no change)
    /// @return desc Descriptor after upgrade
    function relationUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a relation (revision bump only)
    /// @param id ID of the relation
    /// @return desc Descriptor after touch
    function relationTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a relation
    /// @param id ID of the relation
    /// @param to New owner address
    /// @return from Previous owner address
    function relationTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Gets the descriptor and elements at a specific revision
    /// @param id ID of the relation
    /// @param rev Revision number
    /// @return desc Descriptor at the revision
    /// @return elems Packed relation elements
    function relationAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a relation
    /// @param id ID of the relation
    /// @return owner Address of the current owner
    function relationOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the rule of a relation
    /// @param id ID of the relation
    /// @return rule Possession rule definition
    function relationRule(uint64 id) external view returns (RelationRule memory rule);

    /// @notice Checks if a relation admits a given kind
    /// @param id Relation ID
    /// @param rev Revision of the relation
    /// @param kind Tail kind ID
    /// @return admit Whether the kind is admitted
    /// @return effKind Matched kind (0 = wildcard match)
    /// @return effDegs Degree bounds for the matched kind
    /// @return totalKind Total-kind marker (2^48-1 if used)
    /// @return totalDegs Degree bounds for total-kind
    function relationAdmit(uint64 id, uint32 rev, uint64 kind)
        external
        view
        returns (bool admit, uint48 effKind, uint16 effDegs, uint48 totalKind, uint16 totalDegs);

    /// @notice Gets the latest revision of a relation (0 if nonexistent)
    /// @param id ID of the relation
    /// @return rev Latest revision number
    function relationStatus(uint64 id) external view returns (uint32 rev);

    /// @notice Checks if all given relations are active (revision > 0)
    /// @param id Array of relation IDs
    /// @return active True if all exist and are active
    function relationStatus(uint64[] memory id) external view returns (bool active);
}
