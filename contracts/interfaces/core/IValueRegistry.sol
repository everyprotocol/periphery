// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {TokenSpec, TokenStandard} from "../../types/Token.sol";

/// @title IValueRegistry
/// @notice Interface for registering and managing values
interface IValueRegistry {
    // --- Events ---

    /// @notice Emitted when a new value is registered
    /// @param id ID of the newly registered value
    /// @param desc Descriptor of the value
    /// @param code Token contract address
    /// @param data Hash of the underlying asset or metadata
    /// @param spec Token specification (standard, decimals, symbol)
    /// @param owner Address of the initial owner
    event ValueRegistered(uint64 id, Descriptor desc, address code, bytes32 data, TokenSpec spec, address owner);

    /// @notice Emitted when a value is updated
    /// @param id ID of the value
    /// @param desc Updated descriptor (with bumped revision)
    /// @param data New hash of the asset or metadata
    /// @param spec Updated or unchanged token specification
    event ValueUpdated(uint64 id, Descriptor desc, bytes32 data, TokenSpec spec);

    /// @notice Emitted when a value is upgraded (revision of kind/set updated)
    /// @param id ID of the value
    /// @param desc Descriptor after upgrade
    event ValueUpgraded(uint64 id, Descriptor desc);

    /// @notice Emitted when a value is touched (revision bump only, no content change)
    /// @param id ID of the value
    /// @param desc Descriptor after touch
    event ValueTouched(uint64 id, Descriptor desc);

    /// @notice Emitted when ownership of a value is transferred
    /// @param id ID of the value
    /// @param desc Descriptor after the transfer
    /// @param from Previous owner address
    /// @param to New owner address
    event ValueTransferred(uint64 id, Descriptor desc, address from, address to);

    // --- Write Methods ---

    /// @notice Registers a new value token
    /// @param code Token contract address
    /// @param data Hash of the underlying matter or metadata
    /// @param std Token standard (e.g. ERC20)
    /// @param decimals Token's decimal precision
    /// @param symbol Display symbol (max 30 characters)
    /// @return id New value ID
    /// @return desc Descriptor after registration
    function valueRegister(address code, bytes32 data, TokenStandard std, uint8 decimals, string memory symbol)
        external
        returns (uint64 id, Descriptor memory desc);

    /// @notice Updates the data hash of an existing value
    /// @param id Value ID
    /// @param data New data hash
    /// @return desc Updated descriptor (revision bumped)
    function valueUpdate(uint64 id, bytes32 data) external returns (Descriptor memory desc);

    /// @notice Updates the data hash and symbol of an existing value
    /// @param id Value ID
    /// @param data New data hash
    /// @param symbol New display symbol
    /// @return desc Updated descriptor
    function valueUpdate(uint64 id, bytes32 data, string memory symbol) external returns (Descriptor memory desc);

    /// @notice Upgrades the kind/set revision of a value
    /// @param id Value ID
    /// @param kindRev0 New kind revision (0 = no change)
    /// @param setRev0 New set revision (0 = no change)
    /// @return desc Descriptor after upgrade
    function valueUpgrade(uint64 id, uint32 kindRev0, uint32 setRev0) external returns (Descriptor memory desc);

    /// @notice Touches a value, bumping its revision without changing its content
    /// @param id Value ID
    /// @return desc Descriptor after touch
    function valueTouch(uint64 id) external returns (Descriptor memory desc);

    /// @notice Transfers ownership of a value to a new address
    /// @param id Value ID
    /// @param to Address to transfer ownership to
    /// @return from Address of the previous owner
    function valueTransfer(uint64 id, address to) external returns (address from);

    // --- Read Methods ---

    /// @notice Resolves and validates a revision of a value
    /// @param id Value ID
    /// @param rev0 Requested revision (0 = latest)
    /// @return rev Validated revision (0 = not found)
    function valueRevision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /// @notice Returns the descriptor of a value at a specific revision
    /// @param id Value ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the given revision
    function valueDescriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory desc);

    /// @notice Returns descriptor and elements of a value at a specific revision
    /// @param id Value ID
    /// @param rev0 Revision to query (0 = latest)
    /// @return desc Descriptor at the given revision
    /// @return elems Element values at the given revision
    function valueSnapshot(uint64 id, uint32 rev0)
        external
        view
        returns (Descriptor memory desc, bytes32[] memory elems);

    /// @notice Returns the current owner of a value
    /// @param id Value ID
    /// @return owner Current owner's address
    function valueOwner(uint64 id) external view returns (address owner);

    /// @notice Returns the latest descriptor and current owner of a value
    /// @param id Value ID
    /// @return desc Latest descriptor
    /// @return owner Current owner's address
    function valueSota(uint64 id) external view returns (Descriptor memory desc, address owner);

    /// @notice Checks whether all specified values are active (revision > 0)
    /// @param ids Array of value IDs
    /// @return active True if all values exist and are active
    function valueStatus(uint64[] memory ids) external view returns (bool active);
}
