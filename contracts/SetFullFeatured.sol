// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IInteroperable, Interoperable} from "./utils/Interoperable.sol";
import {IRemoteMintable, RemoteMintable} from "./utils/RemoteMintable.sol";
import {Descriptor, SetERC1155Compat} from "./utils/SetERC1155Compat.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetFullFeatured is Ownable, Interoperable, RemoteMintable, SetERC1155Compat {
    error ObjectIdUnspecified();
    error UnsupportedKindId();
    error UnsupportedKindRevision();
    error UnsupportedSetId();
    error UnsupportedSetRevision();
    error CurrentOwnerMismatch();

    uint64 public _kindId;
    uint32 public _kindRev;

    modifier onlySetOwner() override(Interoperable, RemoteMintable) {
        _checkOwner();
        _;
    }

    constructor(address owner, address minter, address setr, uint64 kindId, uint32 kindRev)
        Ownable(owner)
        Interoperable(setr)
        RemoteMintable(minter)
    {
        _kindId = kindId;
        _kindRev = kindRev;
    }

    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        returns (Descriptor memory desc)
    {
        rel;
        data;
        tailSet;
        tailId;
        tailKind;
        desc = _touch(id);
    }

    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        override
        returns (Descriptor memory desc)
    {
        rel;
        data;
        tailSet;
        tailId;
        tailKind;
        desc = _touch(id);
    }

    function onObjectTransfer(uint64 id, address from, address to) external override returns (bytes4) {
        if (_ownerOf(id) != from) revert CurrentOwnerMismatch();
        _transfer(id, to);
        return IInteroperable.onObjectTransfer.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(SetERC1155Compat, Interoperable, RemoteMintable)
        returns (bool)
    {
        return interfaceId == type(IRemoteMintable).interfaceId || interfaceId == type(IInteroperable).interfaceId
            || SetERC1155Compat._supportsInterface(interfaceId);
    }

    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        override
        returns (uint64 id)
    {
        operator;
        context;
        if (id0 == 0) revert ObjectIdUnspecified();
        id = id0;
        Descriptor memory desc = Descriptor(0, 1, _kindRev, _setRev, _kindId, _setId);
        bytes32[] memory elems = data.length > 0 ? abi.decode(data, (bytes32[])) : new bytes32[](0);
        desc = _create(id, desc, elems, to);
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

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://example.com/setfullfeatured/";
    }
}
