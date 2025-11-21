// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ObjectMinterAdmin} from "../utils/ObjectMinterAdmin.sol";
import {ObjectMinterHook} from "../utils/ObjectMinterHook.sol";
import {SetConnected} from "./SetConnected.sol";

abstract contract SetConnectedMintable is SetConnected, ObjectMinterHook, ObjectMinterAdmin {
    // forge-lint: disable-next-line(mixed-case-function)
    function _SetConnectedMintable_initialize(address setRegistry, address objectMinter) internal {
        _SetConnected_initializeFrom(setRegistry);
        _ObjectMinterHook_initialize(objectMinter);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        virtual
        override(SetConnected, ObjectMinterHook)
        returns (bool)
    {
        return _SetConnectedMintable_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetConnectedMintable_supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return _ObjectMinterHook_supportsInterface(interfaceId) || _SetConnected_supportsInterface(interfaceId);
    }
}
