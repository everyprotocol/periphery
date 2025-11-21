// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, KindRegistryClient, Set1155Linked} from "@everyprotocol/periphery/sets/Set1155Linked.sol";
import {SetComposable} from "@everyprotocol/periphery/utils/SetComposable.sol";

contract MySet1155 is Set1155Linked {
    error ZeroKindId();
    error KindRevUnavailable();
    error ObjectIdAutoOnly();

    uint64 _minted;
    uint64 _kindId;
    uint32 _kindRev;

    constructor(address setRegistry, uint64 kindId, uint32 kindRev0) {
        _SetLinked_initializeFrom(setRegistry);

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
}
