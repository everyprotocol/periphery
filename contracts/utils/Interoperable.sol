// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, IInteroperable} from "../interfaces/user/IInteroperable.sol";
import {SetContext} from "./SetContext.sol";

/// @title Interoperable
/// @notice Base contract to enable object-level interoperability via the OmniRegistry.
/// @dev Implements the IInteroperable interface and restricts callbacks to only the configured OmniRegistry.
abstract contract Interoperable is IInteroperable {
    error CallerNotOmniRegistry();

    /// @dev Restricts execution to only the configured OmniRegistry.
    modifier onlyOmniRegistry() {
        if (msg.sender != SetContext.getOmniRegistry()) revert CallerNotOmniRegistry();
        _;
    }

    /// @inheritdoc IInteroperable
    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        onlyOmniRegistry
        returns (Descriptor memory od)
    {
        // Must be implemented by inheriting contract
    }

    /// @inheritdoc IInteroperable
    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        onlyOmniRegistry
        returns (Descriptor memory od)
    {
        // Must be implemented by inheriting contract
    }

    /// @inheritdoc IInteroperable
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
        return interfaceId == type(IInteroperable).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
