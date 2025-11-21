// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISetRegistry} from "../interfaces/core/ISetRegistry.sol";
import {ZeroSetRegistry} from "../utils/Errors.sol";
import {KindRegistryClient} from "../utils/KindRegistryClient.sol";
import {SetComposable} from "../utils/SetComposable.sol";
import {SetRegistryAdmin} from "../utils/SetRegistryAdmin.sol";
import {SetRegistryHook} from "../utils/SetRegistryHook.sol";
import {Descriptor, SetSolo} from "./SetSolo.sol"; // forge-lint: disable-line(unused-import)

abstract contract SetLinked is SetSolo, SetRegistryHook, SetRegistryAdmin, KindRegistryClient {
    error ZeroSetId();
    error ZeroSetRev();

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetLinked_initialize(address setRegistry, address kindRegistry) internal {
        _SetRegistryHook_initialize(setRegistry);
        _KindRegistryClient_initialize(kindRegistry);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetLinked_initializeFrom(address setRegistry) internal {
        _SetRegistryHook_initialize(setRegistry);
        _KindRegistryClient_intializeFrom(setRegistry);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        virtual
        override(SetSolo, SetRegistryHook)
        returns (bool)
    {
        return _SetLinked_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _objectURI() internal view virtual override returns (string memory) {
        (address setReg, uint64 setId,) = SetComposable.getSetInfo();
        if (setReg == address(0)) revert ZeroSetRegistry();
        if (setId == 0) revert ZeroSetId();
        return ISetRegistry(setReg).setURI(setId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetLinked_supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return _SetRegistryHook_supportsInterface(interfaceId) || _SetSolo_supportsInterface(interfaceId);
    }
}
