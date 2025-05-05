// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, SetERC1155Compat} from "./utils/SetERC1155Compat.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetERC1155 is SetERC1155Compat {
    error UnsupportedKindId();
    error UnsupportedKindRevision();
    error UnsupportedSetId();
    error UnsupportedSetRevision();

    uint64 internal _minted;
    Descriptor internal _initialDesc;

    constructor(uint64 kindId, uint32 kindRev, uint64 setId, uint32 setRev) {
        _initialDesc = Descriptor(0, 1, kindRev, setRev, kindId, setId);
    }

    function mint(address to, bytes32[] memory elems) external returns (uint64 id, Descriptor memory desc) {
        id = ++_minted;
        desc = _initialDesc;
        _create(id, desc, elems, to);
        _postCreate(id, desc, elems, to);
    }

    function update(uint64 id, bytes32[] memory elems) external onlyObjectOwner(id) returns (Descriptor memory desc) {
        desc = _update(id, elems);
        _postUpdate(id, desc, elems);
    }

    function _kindRevision(uint64 kindId, uint32 kindRev0) internal view virtual override returns (uint32) {
        if (kindId != _initialDesc.kindId) revert UnsupportedKindId();
        if (kindRev0 > _initialDesc.kindRev) revert UnsupportedKindRevision();
        return kindRev0 == 0 ? _initialDesc.kindRev : kindRev0;
    }

    function _setRevision(uint64 setId, uint32 setRev0) internal view virtual override returns (uint32) {
        if (setId != _initialDesc.setId) revert UnsupportedSetId();
        if (setRev0 > _initialDesc.setRev) revert UnsupportedSetRevision();
        return setRev0 == 0 ? _initialDesc.setRev : setRev0;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://example.com/seterc1155/";
    }
}
