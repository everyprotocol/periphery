// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/// @title IKindRegistry
/// @notice Interface for managing and registering object kinds
interface IKindRegistry {
    // --- Events ---

    /// @notice Emitted when a new kind is registered
    /// @param id Kind ID
    /// @param desc Descriptor after registration
    /// @param code Code hash associated with the kind
    /// @param data Data hash associated with the kind
    /// @param elemSpec Element type layout for objects of this kind
    /// @param rels Supported relation IDs
    /// @param owner Owner address of the kind
    event KindRegistered(
        uint64 id, Descriptor desc, bytes32 code, bytes32 data, uint8[] elemSpec, uint64[] rels, address owner
    );

    /// @notice Emitted when a kind is updated
    /// @param id Kind ID
    /// @param desc Updated descriptor
    /// @param code Updated code hash
    /// @param data Updated data hash
    /// @param rels Updated supported relations
    event KindUpdated(uint64 id, Descriptor desc, bytes32 code, bytes32 data, uint64[] rels);

    /// @notice Emitted when a kind is upgraded
    /// @param id Kind ID
    /// @param desc Descriptor after upgrade
    event KindUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a kind is touched (revision bump only)
    /// @param id Kind ID
    /// @param desc Descriptor after touch
    event KindTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when kind ownership is transferred
    /// @param id Kind ID
    /// @param desc Descriptor after the transfer
    /// @param from Previous owner
    /// @param to New owner
    event KindTransferred(uint64 id, Descriptor desc, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new kind
    /// @param code Code hash of the kind
    /// @param data Data hash of the kind
    /// @param elemSpec Element type layout for objects of this kind
    /// @param rels Supported relation IDs
    /// @return id New kind ID
    /// @return desc Descriptor after registration
    function kindRegister(bytes32 code, bytes32 data, uint8[] memory elemSpec, uint64[] memory rels)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates code and/or data of an existing kind
    /// @param id Kind ID
    /// @param code New code hash (0 = skip)
    /// @param data New data hash (0 = skip)
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, bytes32 code, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates supported relations of an existing kind
    /// @param id Kind ID
    /// @param rels Updated relation list
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, uint64[] memory rels) external returns (Descriptor memory desc);

    /// @notice Updates code, data, and relations of an existing kind
    /// @param id Kind ID
    /// @param code New code hash (0 = skip)
    /// @param data New data hash (0 = skip)
    /// @param rels Updated relation list
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, bytes32 code, bytes32 data, uint64[] memory rels)
        external
        returns (Descriptor memory desc);

    /// @notice Upgrades kind/set revision of an existing kind
    /// @param id Kind ID
    /// @param kindRev New kind revision (0 = skip)
    /// @param setRev New set revision (0 = skip)
    /// @return desc Descriptor after upgrade
    function kindUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a kind (bumps revision with no content changes)
    /// @param id Kind ID
    /// @return desc Descriptor after touch
    function kindTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a kind
    /// @param id Kind ID
    /// @param to New owner address
    /// @return from Previous owner address
    function kindTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Resolves and validates a specific revision
    /// @param id Kind ID
    /// @param rev0 Revision to check (0 = latest)
    /// @return rev Valid revision number (0 if not found)
    function kindRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /// @notice Returns the descriptor at a given revision
    /// @param id Kind ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at that revision
    function kindDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Returns descriptor and elements at a specific revision
    /// @param id Kind ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the revision
    /// @return elems Element hashes of the kind at the revision
    function kindSnapshot(uint64 id, uint32 rev0) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Returns the current owner of a kind
    /// @param id Kind ID
    /// @return owner Owner address
    function kindOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the latest descriptor and current owner of a kind
    /// @param id Kind ID
    /// @return desc Latest descriptor
    /// @return owner Current owner address
    function kindSota(uint64 id) external view returns (Descriptor memory desc, address owner);

    /// @notice Checks whether all specified kinds are active (rev > 0)
    /// @param ids List of kind IDs
    /// @return active True if all specified kinds exist and are active
    function kindStatus(uint64[] memory ids) external view returns (bool active);

    /// @notice Checks whether a kind at a given revision admits a specific relation
    /// @param kind Kind ID
    /// @param rev Kind revision (0 = latest)
    /// @param rel Relation ID to check
    /// @return admit Whether the relation is admitted
    /// @return relRev Specific relation revision admitted (0 = latest)
    function kindAdmit(uint64 kind, uint32 rev, uint64 rel) external view returns (bool admit, uint32 relRev);
}
