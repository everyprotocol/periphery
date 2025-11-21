// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISoke} from "../../interfaces/ISoke.sol";
import {Descriptor, IERC165, IObjectInteractionHook} from "../../interfaces/user/IObjectInteractionHook.sol";
import {ZeroOmniRegistry, ZeroSetRegistry} from "./Errors.sol";
import {SetComposable} from "./SetComposable.sol";

/// @title Interoperable
/// @notice Base contract to enable object-level interoperability via the OmniRegistry.
/// @dev Implements the IInteroperable interface and restricts callbacks to only the configured OmniRegistry.
abstract contract ObjectInteractionHook is IObjectInteractionHook {
    error NotOmniRegistry();

    // forge-lint: disable-next-line(mixed-case-function)
    function _ObjectInteractionHook_initialize(address omniRegistry) internal {
        if (omniRegistry == address(0)) revert ZeroOmniRegistry();
        SetComposable.putOmniRegistry(omniRegistry);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _ObjectInteractionHook_initializeFrom(address setRegistry) internal {
        if (setRegistry == address(0)) revert ZeroSetRegistry();
        _ObjectInteractionHook_initialize(ISoke(setRegistry).omniRegistry());
    }

    /// @dev Restricts execution to only the configured OmniRegistry.
    modifier onlyOmniRegistry() {
        _onlyOmniRegistry();
        _;
    }

    function _onlyOmniRegistry() internal view {
        if (msg.sender != SetComposable.getOmniRegistry()) revert NotOmniRegistry();
    }

    /// @inheritdoc IObjectInteractionHook
    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        onlyOmniRegistry
        returns (Descriptor memory od)
    {
        // Must be implemented by inheriting contract
    }

    /// @inheritdoc IObjectInteractionHook
    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        onlyOmniRegistry
        returns (Descriptor memory od)
    {
        // Must be implemented by inheriting contract
    }

    /// @inheritdoc IObjectInteractionHook
    function onObjectTransfer(uint64 id, address from, address to)
        external
        override
        onlyOmniRegistry
        returns (bytes4 selector)
    {
        // Must be implemented by inheriting contract
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool) {
        return _ObjectInteractionHook_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _ObjectInteractionHook_supportsInterface(bytes4 interfaceId) internal pure returns (bool supported) {
        return interfaceId == type(IObjectInteractionHook).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
