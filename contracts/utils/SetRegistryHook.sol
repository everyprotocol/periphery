// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISetRegistryHook} from "../interfaces/user/ISetRegistryHook.sol";
import {SetContext} from "./SetContext.sol";

/// @title SetRegistryHook
/// @notice Base implementation of `ISetRegistryHook` for handling set lifecycle callbacks.
/// @dev Updates the SetContext during set registration, upgrades, and touches.
///      Intended to be inherited by set contracts to handle automatic context tracking.
abstract contract SetRegistryHook is ISetRegistryHook {
    error CallerNotSetRegistry();

    /// @notice Constructs the hook and sets the SetRegistry address in context.
    /// @param setRegistry Address of the SetRegistry contract.
    constructor(address setRegistry) {
        SetContext.setSetRegistry(setRegistry);
    }

    /// @dev Restricts access to only the configured SetRegistry.
    modifier onlySetRegistry() {
        if (msg.sender != SetContext.getSetRegistry()) revert CallerNotSetRegistry();
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
        SetContext.SetContextStorage storage $ = SetContext.ctx();
        $.setId = set;
        $.setRev = od.rev;
        return this.onSetRegister.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetUpdate(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetContext.setSetRev(od.rev);
        return this.onSetUpdate.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetUpgrade(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetContext.setSetRev(od.rev);
        return this.onSetUpgrade.selector;
    }

    /// @inheritdoc ISetRegistryHook
    function onSetTouch(uint64 set, Descriptor memory od) external virtual override onlySetRegistry returns (bytes4) {
        set; // Unused
        SetContext.setSetRev(od.rev);
        return this.onSetTouch.selector;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool supported) {
        return interfaceId == type(ISetRegistryHook).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
