// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ObjectInteractionHook} from "../utils/ObjectInteractionHook.sol";
import {SetLinked} from "./SetLinked.sol";

abstract contract SetConnected is SetLinked, ObjectInteractionHook {
    // forge-lint: disable-next-line(mixed-case-function)
    function _SetConnected_initialize(address setRegistry, address kindRegistry, address omniRegistry) internal {
        _SetLinked_initialize(setRegistry, kindRegistry);
        _ObjectInteractionHook_initialize(omniRegistry);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetConnected_initializeFrom(address setRegistry) internal {
        _SetLinked_initializeFrom(setRegistry);
        _ObjectInteractionHook_initializeFrom(setRegistry);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        virtual
        override(SetLinked, ObjectInteractionHook)
        returns (bool)
    {
        return _SetConnected_supportsInterface(interfaceId);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetConnected_supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return _ObjectInteractionHook_supportsInterface(interfaceId) || _SetLinked_supportsInterface(interfaceId);
    }
}
