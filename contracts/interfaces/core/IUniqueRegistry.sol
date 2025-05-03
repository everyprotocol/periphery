// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {TokenSpec, TokenStandard} from "../../types/TokenSpec.sol";

/**
 * @title IUniqueRegistry
 * @notice Manages registration and updates of uniques
 */
interface IUniqueRegistry {
    // --- Events ---

    /// @notice Emitted when a new unique is registered
    /// @param id ID of the unique
    /// @param desc Descriptor of the unique
    /// @param code Token contract address
    /// @param data Hash of the underlying matter
    /// @param spec Token specification (standard, decimals, symbol, etc.)
    /// @param owner Owner of the registered unique
    event UniqueRegistered(uint64 id, Descriptor desc, address code, bytes32 data, TokenSpec spec, address owner);

    /// @notice Emitted when a unique is updated
    /// @param id ID of the unique
    /// @param desc Updated descriptor
    /// @param data New data hash
    /// @param spec New or unchanged token specification
    event UniqueUpdated(uint64 id, Descriptor desc, bytes32 data, TokenSpec spec);

    /// @notice Emitted when a unique is upgraded
    /// @param id ID of the unique
    /// @param desc Descriptor after upgrade
    event UniqueUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a unique is touched (revision bumped with no content change)
    /// @param id ID of the unique
    /// @param desc Descriptor after touch
    event UniqueTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership of a unique is transferred
    /// @param id ID of the unique
    /// @param from Previous owner
    /// @param to New owner
    event UniqueTransferred(uint64 id, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new unique
    /// @param code Token contract address
    /// @param data Hash of the underlying matter
    /// @param std Token standard (e.g., ERC721)
    /// @param decimals Decimal precision (usually 0 for unique tokens)
    /// @param symbol Token symbol (max 14 chars)
    /// @param begin Inclusive start index of uniqueness
    /// @param end Exclusive end index of uniqueness
    /// @return id ID of the new unique
    /// @return desc Descriptor after registration
    function uniqueRegister(
        address code,
        bytes32 data,
        TokenStandard std,
        uint8 decimals,
        string memory symbol,
        uint64 begin,
        uint64 end
    ) external returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of a unique
    /// @param id Unique ID
    /// @param data New data hash
    /// @return desc Updated descriptor
    function uniqueUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the data hash and symbol of a unique
    /// @param id Unique ID
    /// @param data New data hash
    /// @param symbol New symbol (max 14 chars)
    /// @return desc Updated descriptor
    function uniqueUpdate(uint64 id, bytes32 data, string memory symbol) external returns (Descriptor memory desc);

    /// @notice Upgrades kind/set revision of a unique
    /// @param id Unique ID
    /// @param kindRev New kind revision (0 = skip)
    /// @param setRev New set revision (0 = skip)
    /// @return desc Descriptor after upgrade
    function uniqueUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a unique (revision bump only)
    /// @param id Unique ID
    /// @return desc Descriptor after touch
    function uniqueTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a unique
    /// @param id Unique ID
    /// @param to New owner address
    /// @return from Previous owner address
    function uniqueTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Gets the descriptor and elements at a specific revision
    /// @param id Unique ID
    /// @param rev Revision number
    /// @return desc Descriptor at the revision
    /// @return elems Elements at the revision
    function uniqueAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a unique
    /// @param id Unique ID
    /// @return owner Address of the owner
    function uniqueOwner(uint64 id) external view returns (address owner);

    /// @notice Gets the latest revision of a unique (0 if not found)
    /// @param id Unique ID
    /// @return rev Latest revision
    function uniqueStatus(uint64 id) external view returns (uint32 rev);

    /// @notice Checks if all specified uniques are active (revision > 0)
    /// @param ids Array of unique IDs
    /// @return active True if all exist and are active
    function uniqueStatus(uint64[] memory ids) external view returns (bool active);
}
