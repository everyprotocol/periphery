// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title ISetRegistryHook
/// @notice Interface for set contracts that respond to set lifecycle events.
/// @dev These hooks are invoked by the SetRegistry *before* the respective action is finalized.
///      The set must return the expected selector for the operation to proceed.
interface ISetRegistryHook is IERC165 {
    /// @notice Called before a set is registered.
    /// @param set Set ID being registered.
    /// @param od Initial descriptor of the set.
    /// @return selector Must return `onSetRegister.selector` to confirm the action.
    function onSetRegister(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /// @notice Called before a set is updated.
    /// @param set Set ID being updated.
    /// @param od Updated descriptor of the set.
    /// @return selector Must return `onSetUpdate.selector` to confirm the action.
    function onSetUpdate(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /// @notice Called before a set is upgraded.
    /// @param set Set ID being upgraded.
    /// @param od Descriptor of the set after the upgrade.
    /// @return selector Must return `onSetUpgrade.selector` to confirm the action.
    function onSetUpgrade(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /// @notice Called before a set is touched (bumped revision with no content change).
    /// @param set Set ID being touched.
    /// @param od Descriptor of the set after the touch.
    /// @return selector Must return `onSetTouch.selector` to confirm the action.
    function onSetTouch(uint64 set, Descriptor memory od) external returns (bytes4 selector);
}
