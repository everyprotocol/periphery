// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, ISetRegistry} from "../../interfaces/core/ISetRegistry.sol";
import {ZeroSetRegistry} from "./Errors.sol";
import {SetComposable} from "./SetComposable.sol";

/// @title SetRegistryAdmin
/// @notice Helper for managing privileged registration and upgrade operations with the SetRegistry.
/// @dev Intended to be inherited by set contracts. Assumes `SetContext` is correctly configured.
///      All methods act on the calling contract’s associated set and must be access-controlled.
abstract contract SetRegistryAdmin {
    /// @notice Registers the calling contract as a new set in the SetRegistry.
    /// @param data Content hash (e.g., metadata or schema reference).
    /// @return id Newly assigned set ID.
    /// @return od Descriptor of the registered set.
    function registerSet(bytes32 data) external returns (uint64 id, Descriptor memory od) {
        return _setRegistry().setRegister(data);
    }

    /// @notice Updates the content hash of the set represented by the calling contract.
    /// @param data New content hash.
    /// @return id Set ID.
    /// @return od Updated descriptor of the set.
    function updateSet(bytes32 data) external returns (uint64 id, Descriptor memory od) {
        return _setRegistry().setUpdate(data);
    }

    /// @notice Upgrades the kind or set revision of the calling contract’s set.
    /// @dev Pass 0 to skip updating either kindRev or setRev.
    /// @param kindRev0 New kind revision (0 = no change).
    /// @param setRev0 New set revision (0 = no change).
    /// @return id Set ID.
    /// @return od Descriptor after the upgrade.
    function upgradeSet(uint32 kindRev0, uint32 setRev0) external returns (uint64 id, Descriptor memory od) {
        return _setRegistry().setUpgrade(kindRev0, setRev0);
    }

    /// @notice Increments the revision of the calling contract’s set without changing content.
    /// @return id Set ID.
    /// @return od Descriptor after the touch operation.
    function touchSet() external returns (uint64 id, Descriptor memory od) {
        return _setRegistry().setTouch();
    }

    function _setRegistry() private pure returns (ISetRegistry) {
        address addr = SetComposable.getSetRegistry();
        if (addr == address(0)) revert ZeroSetRegistry();
        return ISetRegistry(addr);
    }
}
