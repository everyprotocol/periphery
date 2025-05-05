// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/**
 * @title ISetRegistry
 * @notice Set registration and management
 */
interface ISetRegistry {
    // --- Events ---

    /// @notice Emitted when a new set is registered
    /// @param id ID of the new set
    /// @param desc Descriptor of the set
    /// @param code Associated contract address
    /// @param data Additional data hash
    /// @param owner Owner of the set
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

    /// @notice Emitted when a set is touched (revision incremented without content change)
    /// @param id ID of the set
    /// @param desc Descriptor after touch
    event SetTouched(uint64 id, Descriptor desc);

    // --- Write Methods ---

    /// @notice Registers a new set
    /// @param data Data hash for the set
    /// @return id New set ID
    /// @return desc Descriptor of the set
    function setRegister(bytes32 data) external returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of a set
    /// @param id Set ID
    /// @param data New data hash
    /// @return desc Updated descriptor
    function setUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Upgrades kind/set revision of a set
    /// @param id Set ID
    /// @param kindRev New kind revision (0 = skip)
    /// @param setRev New set revision (0 = skip)
    /// @return desc Descriptor after upgrade
    function setUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a set (bumps revision with no content change)
    /// @param id Set ID
    /// @return desc Descriptor after touch
    function setTouch(uint64 id) external returns (Descriptor memory desc);

    // --- Read Methods ---

    /// @notice Gets set descriptor and elements at a revision
    /// @param id Set ID
    /// @param rev Revision number
    /// @return desc Descriptor at the revision
    /// @return elems Elements of the set
    function setAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a set
    /// @param id Set ID
    /// @return owner Address of the owner
    function setOwner(uint64 id) external view returns (address owner);

    /**
     * @notice Resolves and validates a set revision
     * @param id Set ID
     * @param rev0 Revision to check (0 = return latest)
     * @return rev Valid revision (0 = not found or invalid)
     */
    function setRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /**
     * @notice Returns the descriptor of a set at a specific revision
     * @param id Set ID
     * @param rev0 Revision to query (0 = latest)
     * @return desc Descriptor at the given revision
     */
    function setDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Gets set descriptor and elements at a revision
    /// @param id Set ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the given revision
    /// @return elems Elements at the given revision
    function setSnapthot(uint64 id, uint32 rev0)
        external
        view
        returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the contract address of a set
    /// @param id Set ID
    /// @return code Address of the contract
    function setContract(uint64 id) external view returns (address code);

    /// @notice Gets the latest revision of a set (0 if not found)
    /// @param id Set ID
    /// @return rev Latest revision
    function setStatus(uint64 id) external view returns (uint32 rev);

    /// @notice Checks whether all given sets are active (rev > 0)
    /// @param ids Array of set IDs
    /// @return active True if all sets exist and are active
    function setStatus(uint64[] memory ids) external view returns (bool active);
}
