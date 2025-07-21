// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title SetContext
/// @notice Library for managing the execution context of a set contract.
/// @dev Stores contextual metadata—such as set ID, registry addresses, and revision numbers—
///      in a dedicated ERC-7201 storage slot. Designed to support modular, pluggable set features.
library SetContext {
    /// @custom:storage-location erc7201:every.storage.SetContext
    struct SetContextStorage {
        // --- Slot 0 ---
        address setRegistry;
        uint64 setId;
        uint32 setRev;
        // --- Slot 1 ---
        address omniRegistry;
        uint96 _reserved0;
        // --- Slot 2 ---
        address kindRegistry;
        uint64 kindId;
        uint32 kindRev;
        // --- Slot 3 ---
        address elemRegistry;
        uint96 _reserved1;
        // --- Slot 4 ---
        address objectMinter;
        uint96 _reserved2;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("every.storage.SetContext")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant LOCATION = 0x9a9ae33f5929d69d85755390eef01c6883da9e8043b3c1e288ad073bd8ad3600;

    /// @dev Internal accessor for storage struct.
    function ctx() internal pure returns (SetContextStorage storage $) {
        assembly {
            $.slot := LOCATION
        }
    }

    // --- Write Methods ---

    /// @notice Sets the address of the SetRegistry.
    function setSetRegistry(address setRegistry) internal {
        ctx().setRegistry = setRegistry;
    }

    /// @notice Sets the ID of the current set.
    function setSetId(uint64 setId) internal {
        ctx().setId = setId;
    }

    /// @notice Sets the revision of the current set.
    function setSetRev(uint32 setRev) internal {
        ctx().setRev = setRev;
    }

    /// @notice Sets the address of the KindRegistry.
    function setKindRegistry(address setRegistry) internal {
        ctx().setRegistry = setRegistry;
    }

    /// @notice Sets the kind ID of the current object.
    function setKindId(uint64 kindId) internal {
        ctx().kindId = kindId;
    }

    /// @notice Sets the kind revision of the current object.
    function setKindRev(uint32 kindRev) internal {
        ctx().kindRev = kindRev;
    }

    /// @notice Sets the address of the OmniRegistry.
    function setOmniRegistry(address omniRegistry) internal {
        ctx().omniRegistry = omniRegistry;
    }

    /// @notice Sets the address of the ObjectMinter.
    function setObjectMinter(address objectMinter) internal {
        ctx().objectMinter = objectMinter;
    }

    // --- Read Methods ---

    /// @notice Gets the address of the SetRegistry.
    function getSetRegistry() internal view returns (address) {
        return ctx().setRegistry;
    }

    /// @notice Gets the ID of the current set.
    function getSetId() internal view returns (uint64) {
        return ctx().setId;
    }

    /// @notice Gets the revision of the current set.
    function getSetRev() internal view returns (uint32) {
        return ctx().setRev;
    }

    /// @notice Gets the address of the OmniRegistry.
    function getOmniRegistry() internal view returns (address) {
        return ctx().omniRegistry;
    }

    /// @notice Gets the address of the KindRegistry.
    function getKindRegistry() internal view returns (address) {
        return ctx().kindRegistry;
    }

    /// @notice Gets the kind ID of the current object.
    function getKindId() internal view returns (uint64) {
        return ctx().kindId;
    }

    /// @notice Gets the kind revision of the current object.
    function getKindRev() internal view returns (uint32) {
        return ctx().kindRev;
    }

    /// @notice Gets the address of the ObjectMinter.
    function getObjectMinter() internal view returns (address) {
        return ctx().objectMinter;
    }
}
