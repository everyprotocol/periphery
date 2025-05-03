// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, SetERC1155Compat} from "@everyprotocol/periphery/sets/SetERC1155Compat.sol";

contract MySet1155 is SetERC1155Compat {
    error UnsupportedKindId();
    error UnsupportedKindRevision();
    error UnsupportedSetId();
    error UnsupportedSetRevision();

    uint64 internal _minted;
    uint64 public _kindId;
    uint32 public _kindRev;
    uint64 public _setId;
    uint32 public _setRev;

    constructor(uint64 kindId, uint32 kindRev, uint64 setId, uint32 setRev) {
        _kindId = kindId;
        _kindRev = kindRev;
        _setId = setId;
        _setRev = setRev;
    }

    function mint(address to, bytes32[] memory elems) external returns (uint64 id, Descriptor memory desc) {
        (id, desc) = _preCreate(0, elems, to);
        _create(id, desc, elems, to);
        _postCreate(id, desc, elems, to);
    }

    function update(uint64 id, bytes32[] memory elems) external onlyObjectOwner(id) returns (Descriptor memory desc) {
        desc = _update(id, elems);
        _postUpdate(id, desc, elems);
    }

    function _preCreate(uint64 id0, bytes32[] memory elems, address owner)
        internal
        virtual
        override
        returns (uint64 id, Descriptor memory desc)
    {
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
        return "https://example.com/myset1155/{id}/{rev}/meta";
    }

    function _uri(uint64 id, uint32 rev) internal view virtual override returns (string memory) {
        return string(abi.encodePacked("https://example.com/myset1155/", toString(id), "/", toString(rev), "/meta"));
    }

    function _setURI() internal view virtual override returns (string memory) {
        return "https://example.com/myset1155/meta";
    }

    function _setKindRevision(uint32 newRev) external {
        _kindRev = newRev;
    }

    function _setSetRevision(uint32 newRev) external {
        _setRev = newRev;
    }

    // Helper to convert uint to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
