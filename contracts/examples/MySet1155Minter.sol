// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, KindRegistryClient, Set1155Linked} from "@everyprotocol/periphery/sets/Set1155Linked.sol";
import {ObjectMinterAdmin} from "@everyprotocol/periphery/sets/utils/ObjectMinterAdmin.sol";
import {ObjectMinterHook} from "@everyprotocol/periphery/sets/utils/ObjectMinterHook.sol";
import {SetComposable} from "@everyprotocol/periphery/sets/utils/SetComposable.sol";

contract MySet1155Minter is Set1155Linked, ObjectMinterHook, ObjectMinterAdmin {
    error ZeroKindId();
    error KindRevUnavailable();
    error ObjectIdAutoOnly();

    uint64 _minted;
    uint64 _kindId;
    uint32 _kindRev;

    constructor(address setRegistry, address objectMinter, uint64 kindId, uint32 kindRev0) {
        _SetLinked_initializeFrom(setRegistry);
        _ObjectMinterHook_initialize(objectMinter);

        uint32 kindRev = KindRegistryClient.checkKindRevision(kindId, kindRev0);
        if (kindRev == 0) revert KindRevUnavailable();

        _kindId = kindId;
        _kindRev = kindRev;
    }

    function mint(address to, uint64 id0, bytes calldata data) external returns (uint64 id, Descriptor memory od) {
        if (id0 != 0) revert ObjectIdAutoOnly();
        id = ++_minted;
        bytes32[] memory elems = abi.decode(data, (bytes32[]));
        (uint64 setId, uint32 setRev) = SetComposable.getSetIdRev();
        od = Descriptor({traits: 0, rev: 1, kindRev: _kindRev, setRev: setRev, setId: setId, kindId: _kindId});
        _create(to, id, od, elems);
        _postCreate(to, id, od, elems);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override(ObjectMinterHook, Set1155Linked)
        returns (bool)
    {
        return _ObjectMinterHook_supportsInterface(interfaceId) || _Set1155Linked_supportsInterface(interfaceId);
    }

    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        override
        returns (uint64 id)
    {}
}
