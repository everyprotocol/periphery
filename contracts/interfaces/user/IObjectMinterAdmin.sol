// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IObjectMinter, MintPolicy} from "../../interfaces/core/IObjectMinter.sol";

/// @title IObjectMinterAdmin
/// @notice Interface for managing mint policies on the object minter
/// @dev All functions apply to the set represented by the calling contract and must be access-controlled
interface IObjectMinterAdmin {
    /**
     * @notice Adds a new mint policy for the set represented by the calling contract
     * @param policy The policy configuration to add
     * @return index Assigned policy index
     */
    function addMintPolicy(MintPolicy memory policy) external returns (uint32 index);

    /**
     * @notice Disables a mint policy for the set represented by the calling contract
     * @param index Index of the policy to disable
     */
    function disableMintPolicy(uint32 index) external;

    /**
     * @notice Enables a mint policy for the set represented by the calling contract
     * @param index Index of the policy to enable
     */
    function enableMintPolicy(uint32 index) external;
}
