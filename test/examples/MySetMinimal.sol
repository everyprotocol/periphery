// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, Set} from "@periphery/sets/Set.sol";

contract MySetMinimal is Set {
    error MintSpecificIdUnsupported();
    error UnsupportedKindId(); // only a preset kind ID is supported
    error UnsupportedKindRevision(); // kindRev0 > _kindRev
    error UnsupportedSetId(); // only a preset set ID is supported
    error UnsupportedSetRevision(); // setRev0 > _setRev

    uint64 internal _minted;
    uint64 internal _kindId;
    uint32 internal _kindRev;
    uint64 internal _setId;
    uint32 internal _setRev;

    // ai! pass args instead of hardcoded
    constructor() {
        _kindId = 17;
        _kindRev = 1;
        _setId = 18;
        _setRev = 2;
    }

    function mint(address to, bytes32[] memory elems) external returns (uint64 id, Descriptor memory desc) {
        (id, desc) = _preCreate(0, elems, to);
        _create(id, desc, elems, to);
        _postCreate(id, desc, elems, to);
    }

    function _preCreate(uint64 id0, bytes32[] memory elems, address owner)
        internal
        virtual
        override
        returns (uint64 id, Descriptor memory desc)
    {
        if (id0 != 0) revert MintSpecificIdUnsupported();
        elems; // silient warnings
        owner; // silient warnings
        id = ++_minted;
        desc = Descriptor(0, 1, _kindRev, _setRev, _kindId, _setId);
    }

    function _kindRevision(uint64 kindId, uint32 kindRev0) internal view virtual override returns (uint32) {
        if (kindId != _kindId) revert UnsupportedKindId();
        if (kindRev0 > _kindRev) revert UnsupportedKindRevision();
        return kindRev0 == 0 ? _kindRev : kindRev0;
    }

    function _setRevision(uint64 setId, uint32 setRev0) internal view virtual override returns (uint32) {
        if (setId != _setId) revert UnsupportedSetId();
        if (setRev0 > _setRev) revert UnsupportedSetRevision();
        return setRev0 == 0 ? _setRev : setRev0;
    }

    function _uri() internal view virtual override returns (string memory) {
        return "http://image.local/mysetminimal/{id}/{rev}/meta";
    }
}
