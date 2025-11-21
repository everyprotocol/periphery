// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/// @title ISetRegistry
/// @notice Interface for registering and managing sets
interface ISetRegistry {
    // --- Events ---

    /// @notice Emitted when a new set is registered
    /// @param id ID of the new set
    /// @param desc Set descriptor after registration
    /// @param code Address of the associated set contract
    /// @param data Hash of the associated matter (external content)
    /// @param owner Owner address of the set
    event SetRegistered(uint64 id, Descriptor desc, address code, bytes32 data, address owner);

    /// @notice Emitted when a set is updated
    /// @param id ID of the set
    /// @param desc Updated descriptor
    /// @param data New data hash
    event SetUpdated(uint64 id, Descriptor desc, bytes32 data);

    /// @notice Emitted when a set is upgraded
    /// @param id ID of the set
    /// @param desc Descriptor after upgrade
    event SetUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a set is touched (revision bumped without content change)
    /// @param id ID of the set
    /// @param desc Descriptor after touch
    event SetTouched(uint64 id, Descriptor desc);

    // --- Write Methods ---

    /// @notice Registers a new set
    /// @param data Hash of external content (e.g. metadata or schema)
    /// @return id ID of the new set
    /// @return desc Descriptor after registration
    function setRegister(bytes32 data) external returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of an existing set
    /// @param id ID of the set
    /// @param data New data hash
    /// @return desc Updated descriptor
    function setUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Upgrades the kind or set revision
    /// @param id ID of the set
    /// @param kindRev New kind revision (0 to skip)
    /// @param setRev New set revision (0 to skip)
    /// @return desc Descriptor after upgrade
    function setUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a set (increments revision without any changes)
    /// @param id ID of the set
    /// @return desc Descriptor after touch
    function setTouch(uint64 id) external returns (Descriptor memory desc);

    // --- Read Methods ---

    /// @notice Returns the URI template for objects in the given set
    /// @dev The returned template includes `{id}` and `{rev}` placeholders,
    ///      which clients should replace with the object ID and revision number
    ///      to construct the full object URI off-chain.
    /// @param id Set ID
    /// @return uri Template URI string for objects in the specified set
    function setURI(uint64 id) external view returns (string memory uri);

    /// @notice Returns the fully resolved URI for a specific object in a set
    /// @dev Substitutes `{id}` and `{rev}` in the set’s URI template using the
    ///      provided object ID and revision.
    /// @param id Set ID
    /// @param objId Object ID (within the set)
    /// @param objRev Object revision number
    /// @return uri Fully resolved URI string for the specified object revision
    function setURI(uint64 id, uint64 objId, uint32 objRev) external view returns (string memory uri);

    /// @notice Resolves and validates a specific revision
    /// @param id Set ID
    /// @param rev0 Requested revision (0 = latest)
    /// @return rev Validated revision (0 if not found)
    function setRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /// @notice Returns the descriptor at a given revision
    /// @param id Set ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor of the set at the specified revision
    function setDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Returns descriptor and elements of a set at a specific revision
    /// @param id Set ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the revision
    /// @return elems Packed element list
    function setSnapshot(uint64 id, uint32 rev0) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Returns the current owner of a set
    /// @param id Set ID
    /// @return owner Owner address
    function setOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the latest descriptor and current owner
    /// @param id Set ID
    /// @return desc Latest descriptor
    /// @return owner Current owner
    function setSota(uint64 id) external view returns (Descriptor memory desc, address owner);

    /// @notice Checks whether all provided set IDs are active
    /// @param ids List of set IDs
    /// @return active True if all sets have a revision > 0
    function setStatus(uint64[] memory ids) external view returns (bool active);

    /// @notice Returns the contract address associated with a set
    /// @param id Set ID
    /// @return code Address of the deployed contract
    function setContract(uint64 id) external view returns (address code);
}
