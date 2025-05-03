// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IInteroperable is IERC165 {
    // ------------------------
    // Set Management Callbacks
    // ------------------------
    function onSetRegister(uint64 set, Descriptor memory desc) external returns (bytes4);

    function onSetUpdate(uint64 set, Descriptor memory desc) external returns (bytes4);

    function onSetUpgrade(uint64 set, Descriptor memory desc) external returns (bytes4);

    function onSetTouch(uint64 set, Descriptor memory desc) external returns (bytes4);

    // ----------------------------
    // Object Interaction Callbacks
    // ----------------------------
    function onObjectTouch(uint64 id) external returns (bytes4, uint32);

    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory desc);

    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory desc);

    function onObjectTransfer(uint64 id, address from, address to) external returns (bytes4);
}
