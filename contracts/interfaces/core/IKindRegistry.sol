// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {ElementType} from "../../types/Element.sol";

/**
 * @title IKindRegistry
 * @notice Kind registration and management
 */
interface IKindRegistry {
    // --- Events ---

    /// @notice Emitted when a new kind is registered
    /// @param id ID of the kind
    /// @param desc Descriptor of the kind
    /// @param code Code hash associated with the kind
    /// @param data Data hash associated with the kind
    /// @param elemSpec Element types of objects in this kind
    /// @param rels Supported relation IDs
    /// @param owner Owner address of the kind
    event KindRegistered(
        uint64 id, Descriptor desc, bytes32 code, bytes32 data, ElementType[] elemSpec, uint64[] rels, address owner
    );

    /// @notice Emitted when a kind is updated
    /// @param id ID of the kind
    /// @param desc Updated descriptor
    /// @param code New code hash
    /// @param data New data hash
    /// @param rels Updated relation array
    event KindUpdated(uint64 id, Descriptor desc, bytes32 code, bytes32 data, uint64[] rels);

    /// @notice Emitted when a kind is upgraded
    /// @param id ID of the kind
    /// @param desc Descriptor after upgrade
    event KindUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a kind is touched (revision bump only)
    /// @param id ID of the kind
    /// @param desc Descriptor after touch
    event KindTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when a kind is transferred
    /// @param id ID of the kind
    /// @param from Previous owner
    /// @param to New owner
    event KindTransferred(uint64 id, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new kind
    /// @param code Code hash of the kind
    /// @param data Data hash of the kind
    /// @param elemSpec Element types of objects in this kind
    /// @param rels Supported relation IDs
    /// @return id New kind ID
    /// @return desc Descriptor of the new kind
    function kindRegister(bytes32 code, bytes32 data, ElementType[] memory elemSpec, uint64[] memory rels)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates code and/or data of a kind
    /// @param id Kind ID
    /// @param code New code hash (0 = skip)
    /// @param data New data hash (0 = skip)
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, bytes32 code, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the relation array of a kind
    /// @param id Kind ID
    /// @param rels New relation array
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, uint64[] memory rels) external returns (Descriptor memory desc);

    /// @notice Updates code, data, and relations of a kind
    /// @param id Kind ID
    /// @param code New code hash (0 = skip)
    /// @param data New data hash (0 = skip)
    /// @param rels New relation array
    /// @return desc Updated descriptor
    function kindUpdate(uint64 id, bytes32 code, bytes32 data, uint64[] memory rels)
        external
        returns (Descriptor memory desc);

    /// @notice Upgrades a kind's revision and/or set revision
    /// @param id Kind ID
    /// @param kindRev New kind revision (0 = skip)
    /// @param setRev New set revision (0 = skip)
    /// @return desc Descriptor after upgrade
    function kindUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a kind (revision bump only)
    /// @param id Kind ID
    /// @return desc Descriptor after touch
    function kindTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers kind ownership
    /// @param id Kind ID
    /// @param to New owner address
    /// @return from Previous owner address
    function kindTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Gets kind snapshot at a revision
    /// @param id Kind ID
    /// @param rev Revision number
    /// @return desc Descriptor at the revision
    /// @return elems Elements of the kind
    function kindAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a kind
    /// @param id Kind ID
    /// @return owner Address of the owner
    function kindOwner(uint64 id) external view returns (address owner);

    /// @notice Checks if a kind admits a relation
    /// @param kind Kind ID
    /// @param rev Kind revision
    /// @param rel Relation ID
    /// @return admit Whether the relation is admitted
    /// @return relRev Specific relation revision (0 = latest)
    function kindAdmit(uint64 kind, uint32 rev, uint64 rel) external view returns (bool admit, uint32 relRev);

    /// @notice Gets latest revision of a kind (0 = not found)
    /// @param id Kind ID
    /// @return rev Latest revision number
    function kindStatus(uint64 id) external view returns (uint32 rev);

    /// @notice Checks if all specified kinds are active (rev > 0)
    /// @param ids Array of kind IDs
    /// @return active True if all kinds exist and are active
    function kindStatus(uint64[] memory ids) external view returns (bool active);
}
