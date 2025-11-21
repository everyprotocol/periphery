// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IKindRegistry} from "../../interfaces/Core/IKindRegistry.sol";
import {ISoke} from "../../interfaces/ISoke.sol";
import {ZeroKindRegistry, ZeroSetRegistry} from "./Errors.sol";
import {SetComposable} from "./SetComposable.sol";

abstract contract KindRegistryClient {
    // forge-lint: disable-next-line(mixed-case-function)
    function _KindRegistryClient_initialize(address kindRegistry) internal {
        if (kindRegistry == address(0)) revert ZeroKindRegistry();
        SetComposable.putKindRegistry(kindRegistry);
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _KindRegistryClient_intializeFrom(address setRegistry) internal {
        if (setRegistry == address(0)) revert ZeroSetRegistry();
        _KindRegistryClient_initialize(ISoke(setRegistry).kindRegistry());
    }

    function checkKindRevision(uint64 kindId, uint32 kindRev0) internal view returns (uint32) {
        address c = SetComposable.getKindRegistry();
        if (c == address(0)) revert ZeroKindRegistry();
        return IKindRegistry(c).kindRevision(kindId, kindRev0);
    }
}
