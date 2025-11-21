// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISetRegistry} from "../interfaces/core/ISetRegistry.sol";
import {Descriptor, Set1155Solo} from "./Set1155Solo.sol"; // forge-lint: disable-line(unused-import)
import {ZeroSetRegistry} from "./utils/Errors.sol";
import {KindRegistryClient} from "./utils/KindRegistryClient.sol";
import {SetComposable} from "./utils/SetComposable.sol";
import {SetRegistryAdmin} from "./utils/SetRegistryAdmin.sol";
import {SetRegistryHook} from "./utils/SetRegistryHook.sol";

abstract contract Set1155Linked is Set1155Solo, SetRegistryHook, SetRegistryAdmin, KindRegistryClient {
    error ZeroSetId();
    error ZeroSetRev();

    // forge-lint: disable-next-line(mixed-case-function)
    function _Set1155Linked_initialize(address setRegistry, address kindRegistry) internal {
        _SetRegistryHook_initialize(setRegistry);
        _KindRegistryClient_initialize(kindRegistry);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _Set1155Linked_initializeFrom(address setRegistry) internal {
        _SetRegistryHook_initialize(setRegistry);
        _KindRegistryClient_intializeFrom(setRegistry);
    }

    function getSetRegistry() internal view returns (address) {
        return SetComposable.getSetRegistry();
    }

    function getSetIdRev() internal view returns (uint64, uint32) {
        return SetComposable.getSetIdRev();
    }

    function getSetId() internal view returns (uint64) {
        return SetComposable.getSetId();
    }

    function getSetRev() internal view returns (uint32) {
        return SetComposable.getSetRev();
    }

    function checkKindRev(uint64 kindId, uint32 kindRev0) internal view returns (uint32) {
        return KindRegistryClient.checkKindRevision(kindId, kindRev0);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        virtual
        override(Set1155Solo, SetRegistryHook)
        returns (bool)
    {
        return _Set1155Linked_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _Set1155Linked_supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return _SetRegistryHook_supportsInterface(interfaceId) || _Set1155Solo_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _objectURI() internal view virtual override returns (string memory) {
        (address setReg, uint64 setId,) = SetComposable.getSetInfo();
        if (setReg == address(0)) revert ZeroSetRegistry();
        if (setId == 0) revert ZeroSetId();
        return ISetRegistry(setReg).setURI(setId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _tokenURI(uint64 id, uint32 rev) internal view virtual override returns (string memory) {
        (address setReg, uint64 setId,) = SetComposable.getSetInfo();
        if (setReg == address(0)) revert ZeroSetRegistry();
        if (setId == 0) revert ZeroSetId();
        return ISetRegistry(setReg).setURI(setId, id, rev);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _contractURI() internal view virtual override returns (string memory) {
        (address setReg, uint64 setId, uint32 setRev) = SetComposable.getSetInfo();
        if (setReg == address(0)) revert ZeroSetRegistry();
        if (setId == 0) revert ZeroSetId();
        if (setRev == 0) revert ZeroSetRev();
        return ISetRegistry(setReg).setURI(1, setId, setRev);
    }
}
