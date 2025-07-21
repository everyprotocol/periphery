// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISetRegistry} from "../interfaces/core/ISetRegistry.sol";
import {Descriptor, IERC165, ISet} from "../interfaces/user/ISet.sol";
import {SetContext} from "./SetContext.sol";
import {ISetRegistryHook, SetRegistryHook} from "./SetRegistryHook.sol";
import {SetSolo} from "./SetSolo.sol";

/// @title SetBase
/// @notice Foundation contract for set implementations combining SetSolo and SetRegistryHook logic.
abstract contract SetBase is SetSolo, SetRegistryHook {
    /// @notice Initializes the contract with the given SetRegistry address.
    /// @param setRegistry The address of the SetRegistry contract.
    constructor(address setRegistry) SetRegistryHook(setRegistry) {}

    /// @inheritdoc IERC165
    /// @dev Combines interface support from SetSolo and SetRegistryHook.
    function supportsInterface(bytes4 interfaceId) external pure override(SetSolo, SetRegistryHook) returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(ISet).interfaceId
            || interfaceId == type(ISetRegistryHook).interfaceId;
    }

    /// @dev Resolves the valid revision for a set using the SetRegistry.
    /// @param setId The set ID.
    /// @param setRev0 The requested revision (0 = latest).
    /// @return The resolved revision (0 if not found).
    function _resolveSetRev(uint64 setId, uint32 setRev0) internal view virtual override returns (uint32) {
        return ISetRegistry(SetContext.getSetRegistry()).setRevision(setId, setRev0);
    }

    /// @dev Retrieves the URI template for the current set using the SetRegistry.
    /// @return URI template string containing `{id}` and `{rev}` placeholders.
    function _uri() internal view virtual override returns (string memory) {
        return ISetRegistry(SetContext.getSetRegistry()).setURI(SetContext.getSetId());
    }
}
