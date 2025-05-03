// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {TokenSpec, TokenStandard} from "../../types/TokenSpec.sol";

/**
 * @title IValueRegistry
 * @notice Manages registration and updates of values
 */
interface IValueRegistry {
    // --- Events ---

    /// @notice Emitted when a new value is registered
    /// @param id ID of the value
    /// @param desc Descriptor of the value
    /// @param code Token contract address
    /// @param data Hash of the underlying matter
    /// @param spec Token specification (standard, decimals, symbol, etc.)
    /// @param owner Address of the owner
    event ValueRegistered(uint64 id, Descriptor desc, address code, bytes32 data, TokenSpec spec, address owner);

    /// @notice Emitted when a value is updated
    /// @param id ID of the value
    /// @param desc Updated descriptor
    /// @param data New data hash
    /// @param spec Updated or unchanged token specification
    event ValueUpdated(uint64 id, Descriptor desc, bytes32 data, TokenSpec spec);

    /// @notice Emitted when a value is upgraded
    /// @param id ID of the value
    /// @param desc Descriptor after upgrade
    event ValueUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a value is touched (revision bump only)
    /// @param id ID of the value
    /// @param desc Descriptor after touch
    event ValueTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership of a value is transferred
    /// @param id ID of the value
    /// @param from Previous owner
    /// @param to New owner
    event ValueTransferred(uint64 id, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new value
    /// @param code Token contract address
    /// @param data Hash of the token's matter
    /// @param std Token standard (e.g., ERC20)
    /// @param decimals Decimal precision
    /// @param symbol Token symbol (max 14 chars)
    /// @return id New value ID
    /// @return desc Descriptor after registration
    function valueRegister(address code, bytes32 data, TokenStandard std, uint8 decimals, string memory symbol)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of a value
    /// @param id Value ID
    /// @param data New data hash
    /// @return desc Updated descriptor
    function valueUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the data hash and symbol of a value
    /// @param id Value ID
    /// @param data New data hash
    /// @param symbol New symbol (max 14 chars)
    /// @return desc Updated descriptor
    function valueUpdate(uint64 id, bytes32 data, string memory symbol) external returns (Descriptor memory desc);

    /// @notice Upgrades kind/set revision of a value
    /// @param id Value ID
    /// @param kindRev New kind revision (0 = skip)
    /// @param setRev New set revision (0 = skip)
    /// @return desc Descriptor after upgrade
    function valueUpgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /// @notice Touches a value (revision bump only)
    /// @param id Value ID
    /// @return desc Descriptor after touch
    function valueTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a value
    /// @param id Value ID
    /// @param to New owner address
    /// @return from Previous owner address
    function valueTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Gets the descriptor and elements at a specific revision
    /// @param id Value ID
    /// @param rev Revision number
    /// @return desc Descriptor at the revision
    /// @return elems Elements at the revision
    function valueAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Gets the current owner of a value
    /// @param id Value ID
    /// @return owner Address of the owner
    function valueOwner(uint64 id) external view returns (address owner);

    /// @notice Gets the latest revision of a value (0 if not found)
    /// @param id Value ID
    /// @return rev Latest revision number
    function valueStatus(uint64 id) external view returns (uint32 rev);

    /// @notice Checks if all specified values are active (revision > 0)
    /// @param ids Array of value IDs
    /// @return active True if all exist and are active
    function valueStatus(uint64[] memory ids) external view returns (bool active);
}
