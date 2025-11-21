// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISetRegistryHook} from "../../interfaces/user/ISetRegistryHook.sol";
import {ZeroSetRegistry} from "./Errors.sol";
import {SetComposable} from "./SetComposable.sol";

/// @title SetRegistryHook
/// @notice Base implementation of `ISetRegistryHook` for handling set lifecycle callbacks.
/// @dev Updates the SetContext during set registration, upgrades, and touches.
///      Intended to be inherited by set contracts to handle automatic context tracking.
abstract contract SetRegistryHook is ISetRegistryHook {
    error NotSetRegistry();

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetRegistryHook_initialize(address setRegistry) internal {
        if (setRegistry == address(0)) revert ZeroSetRegistry();
        SetComposable.putSetRegistry(setRegistry);
    }

    /// @dev Restricts access to only the configured SetRegistry.
    modifier onlySetRegistry() {
        _onlySetRegistry();
        _;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetRegister(uint64 set, Descriptor memory od)
        external
        virtual
        override
        onlySetRegistry
        returns (bytes4)
    {
        SetComposable.putSetIdRev(set, od.rev);
        return this.onSetRegister.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetUpdate(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetComposable.putSetRev(od.rev);
        return this.onSetUpdate.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetUpgrade(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetComposable.putSetRev(od.rev);
        return this.onSetUpgrade.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetTouch(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetComposable.putSetRev(od.rev);
        return this.onSetTouch.selector;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool supported) {
        return _SetRegistryHook_supportsInterface(interfaceId);
    }

    function _onlySetRegistry() internal view {
        if (msg.sender != SetComposable.getSetRegistry()) revert NotSetRegistry();
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetRegistryHook_supportsInterface(bytes4 interfaceId) internal pure returns (bool supported) {
        return interfaceId == type(ISetRegistryHook).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
