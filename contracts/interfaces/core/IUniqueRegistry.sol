// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {TokenSpec, TokenStandard} from "../../types/Token.sol";

/// @title IUniqueRegistry
/// @notice Interface for registering and managing uniques
interface IUniqueRegistry {
    // --- Events ---

    /// @notice Emitted when a new unique is registered
    /// @param id Unique ID
    /// @param desc Descriptor of the unique
    /// @param code Token contract address
    /// @param data Hash of the underlying asset (e.g., image, model, metadata)
    /// @param spec Token specification (standard, decimals, and symbol)
    /// @param owner Address of the initial owner
    event UniqueRegistered(uint64 id, Descriptor desc, address code, bytes32 data, TokenSpec spec, address owner);

    /// @notice Emitted when a unique is updated
    /// @param id Unique ID
    /// @param desc Updated descriptor (same ID, new revision)
    /// @param data New data hash representing the updated asset
    /// @param spec Updated or unchanged token specification
    event UniqueUpdated(uint64 id, Descriptor desc, bytes32 data, TokenSpec spec);

    /// @notice Emitted when a unique is upgraded to a new revision
    /// @param id Unique ID
    /// @param desc Descriptor after the upgrade (revised kind/set refs)
    event UniqueUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a unique is touched (revision bumped with no content change)
    /// @param id Unique ID
    /// @param desc Descriptor after touch (updated revision only)
    event UniqueTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership of a unique is transferred
    /// @param id Unique ID
    /// @param desc Descriptor after the transfer
    /// @param from Previous owner's address
    /// @param to New owner's address
    event UniqueTransferred(uint64 id, Descriptor desc, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new unique token
    /// @param code Address of the token contract
    /// @param data Hash of the associated matter
    /// @param std Token standard (e.g. ERC721)
    /// @param decimals Number of decimals
    /// @param symbol Display symbol (max 30 characters)
    /// @return id ID of the new unique
    /// @return desc Descriptor after registration
    function uniqueRegister(address code, bytes32 data, TokenStandard std, uint8 decimals, string memory symbol)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of a unique
    /// @param id Unique ID
    /// @param data New data hash
    /// @return desc Updated descriptor
    function uniqueUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the data hash and symbol of a unique
    /// @param id Unique ID
    /// @param data New data hash
    /// @param symbol New display symbol (max 30 characters)
    /// @return desc Updated descriptor
    function uniqueUpdate(uint64 id, bytes32 data, string memory symbol) external returns (Descriptor memory desc);

    /// @notice Upgrades the kind and/or set revision of a unique
    /// @param id Unique ID
    /// @param kindRev New kind revision (0 = no change)
    /// @param setRev New set revision (0 = no change)
    /// @return desc Descriptor after upgrade
    function uniqueUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Bumps the revision of a unique with no content change
    /// @param id Unique ID
    /// @return desc Descriptor after touch
    function uniqueTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a unique token
    /// @param id Unique ID
    /// @param to Address of the new owner
    /// @return from Address of the previous owner
    function uniqueTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Resolves and validates a revision
    /// @param id Unique ID
    /// @param rev0 Requested revision (0 = latest)
    /// @return rev Resolved revision (0 = not found)
    function uniqueRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /// @notice Returns the descriptor at a given revision
    /// @param id Unique ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the specified revision
    function uniqueDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Returns descriptor and elements at a specific revision
    /// @param id Unique ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the revision
    /// @return elems Elements at the revision
    function uniqueSnapshot(uint64 id, uint32 rev0)
        external
        view
        returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Returns the current owner of a unique
    /// @param id Unique ID
    /// @return owner Address of the current owner
    function uniqueOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the latest descriptor and current owner
    /// @param id Unique ID
    /// @return desc Latest descriptor
    /// @return owner Address of the current owner
    function uniqueSota(uint64 id) external view returns (Descriptor memory desc, address owner);

    /// @notice Checks whether all given uniques are active (revision > 0)
    /// @param ids List of unique IDs
    /// @return active True if all exist and are active
    function uniqueStatus(uint64[] memory ids) external view returns (bool active);
}
