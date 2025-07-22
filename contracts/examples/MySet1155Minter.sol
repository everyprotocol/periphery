// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MySet1155} from "./MySet1155.sol";
import {ObjectIdAuto} from "@everyprotocol/periphery/libraries/Allocator.sol";
import {Descriptor, ERC1155Compatible, ISet} from "@everyprotocol/periphery/utils/ERC1155Compatible.sol";
import {IObjectMinter, ObjectMinterAdmin} from "@everyprotocol/periphery/utils/ObjectMinterAdmin.sol";
import {IObjectMinterHook, ObjectMinterHook, SetContext} from "@everyprotocol/periphery/utils/ObjectMinterHook.sol";
import {ISetRegistry, SetRegistryAdmin} from "@everyprotocol/periphery/utils/SetRegistryAdmin.sol";
import {ISetRegistryHook, SetRegistryHook} from "@everyprotocol/periphery/utils/SetRegistryHook.sol";

contract MySet1155Minter is MySet1155, ObjectMinterHook, ObjectMinterAdmin {
    constructor(address setRegistry, address objectMinter, uint64 kindId, uint32 kindRev)
        MySet1155(setRegistry, kindId, kindRev)
        ObjectMinterHook(objectMinter)
    {}

    function supportsInterface(bytes4 interfaceId) external pure override(MySet1155, ObjectMinterHook) returns (bool) {
        return (interfaceId == type(IObjectMinterHook).interfaceId) || MySet1155._supportsInterface(interfaceId);
    }

    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        override
        returns (uint64 id)
    {}
}
