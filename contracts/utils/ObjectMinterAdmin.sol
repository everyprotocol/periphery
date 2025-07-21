// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IObjectMinter, MintPolicy} from "../interfaces/core/IObjectMinter.sol";
import {SetContext} from "./SetContext.sol";

/// @title ObjectMinterAdmin
/// @notice Provides helper functions for managing minting policies via an external ObjectMinter.
/// @dev Designed to be inherited by set contracts. Assumes `SetContext` is properly configured.
///      All functions apply to the calling set and must be protected by access control.
abstract contract ObjectMinterAdmin {
    error InvalidObjectMinterAddress();
    error ObjectIdNotSpecified();
    error CallerNotObjectMinter();

    /// @notice Adds a new minting policy for this set.
    /// @dev Only callable by the set owner or an authorized admin.
    /// @param policy The minting policy to add.
    /// @return index The index of the newly added policy.
    function addMintPolicy(MintPolicy memory policy) external returns (uint32 index) {
        index = _objectMinter().mintPolicyAdd(policy);
    }

    /// @notice Disables an existing minting policy for this set.
    /// @dev Only callable by the set owner or an authorized admin.
    /// @param index The index of the policy to disable.
    function disableMintPolicy(uint32 index) external {
        _objectMinter().mintPolicyDisable(index);
    }

    /// @notice Enables a previously disabled minting policy for this set.
    /// @dev Only callable by the set owner or an authorized admin.
    /// @param index The index of the policy to enable.
    function enableMintPolicy(uint32 index) external {
        _objectMinter().mintPolicyEnable(index);
    }

    /// @notice Returns the configured ObjectMinter for this set.
    /// @dev Reverts if the ObjectMinter is not configured.
    /// @return The IObjectMinter instance.
    function _objectMinter() private view returns (IObjectMinter) {
        return IObjectMinter(SetContext.getObjectMinter());
    }
}
