// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/// @title ISetRegistryAdmin
/// @notice Interface for privileged set registration and upgrade operations
/// @dev All methods operate on the set represented by the calling contract and must be access-controlled
interface ISetRegistryAdmin {
    /**
     * @notice Registers the set represented by the calling contract
     * @param data Content hash (e.g., metadata or schema)
     * @return id Newly assigned set ID
     * @return desc Descriptor of the registered set
     */
    function registerSet(bytes32 data) external returns (uint64 id, Descriptor memory desc);

    /**
     * @notice Updates the content hash for the set represented by the calling contract
     * @param data New content hash
     * @return id Set ID
     * @return desc Updated descriptor
     */
    function updateSet(bytes32 data) external returns (uint64 id, Descriptor memory desc);

    /**
     * @notice Upgrades the kind or set revision of the set represented by the calling contract
     * @dev Pass 0 to skip updating either revision
     * @param kindRev0 New kind revision (0 = no change)
     * @param setRev0 New set revision (0 = no change)
     * @return id Set ID
     * @return desc Descriptor after upgrade
     */
    function upgradeSet(uint32 kindRev0, uint32 setRev0) external returns (uint64 id, Descriptor memory desc);

    /**
     * @notice Increments the revision of the set represented by the calling contract
     * @return id Set ID
     * @return desc Descriptor after revision bump
     */
    function touchSet() external returns (uint64 id, Descriptor memory desc);
}
