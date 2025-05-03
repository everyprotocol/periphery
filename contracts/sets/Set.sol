// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISet} from "../interfaces/user/ISet.sol";

abstract contract Set is ISet {
    error CallerNotObjectOwner();

    error InvalidObjectId();
    error InvalidKindRevision();
    error InvalidSetRevision();
    error InvalidUpgradeRevision();

    error ObjectAlreadyExists();
    error ObjectNotFound();

    error RevisionNotStored();
    error RevisionNotFound();

    error KindRevisionNotFound();
    error SetRevisionNotFound();

    struct ObjectData {
        Descriptor desc;
        address owner;
        bytes32[] elements;
    }

    uint64 private constant ID_MAX = type(uint64).max - 1;

    mapping(uint64 => ObjectData) private _objects;

    modifier onlyObjectOwner(uint64 id) {
        if (_objects[id].desc.rev == 0) revert ObjectNotFound();
        if (_objects[id].owner != msg.sender) revert CallerNotObjectOwner();
        _;
    }

    /// @inheritdoc ISet
    function upgrade(uint64 id, uint32 kindRev, uint32 setRev)
        external
        override
        onlyObjectOwner(id)
        returns (Descriptor memory desc)
    {
        desc = _upgrade(id, kindRev, setRev);
        _postUpgrade(id, desc, kindRev, setRev);
        return desc;
    }

    /// @inheritdoc ISet
    function touch(uint64 id) external override onlyObjectOwner(id) returns (Descriptor memory desc) {
        desc = _touch(id);
        _postTouch(id, desc);
        return desc;
    }

    /// @inheritdoc ISet
    function transfer(uint64 id, address to) external override onlyObjectOwner(id) {
        address from = _transfer(id, to);
        _postTransfer(id, from, to);
    }

    /// @inheritdoc ISet
    function revision(uint64 id, uint32 rev0) external view override returns (uint32 rev) {
        rev = _revision(id, rev0);
    }

    /// @inheritdoc ISet
    function uri() external view override returns (string memory uri_) {
        uri_ = _uri();
    }

    /// @inheritdoc ISet
    function sotaOf(uint64 id) external view override returns (Descriptor memory desc, address owner) {
        (desc, owner) = _sotaOf(id);
    }

    /// @inheritdoc ISet
    function ownerOf(uint64 id) external view override returns (address) {
        return _ownerOf(id);
    }

    /// @inheritdoc ISet
    function descriptorAt(uint64 id, uint32 rev) external view override returns (Descriptor memory) {
        Descriptor memory meta = _objects[id].desc;
        if (meta.rev == 0) revert ObjectNotFound();
        if (rev != 0 && rev != meta.rev) revert RevisionNotStored();
        return meta;
    }

    /// @inheritdoc ISet
    function elementsAt(uint64 id, uint32 rev) external view override returns (bytes32[] memory) {
        Descriptor memory meta = _objects[id].desc;
        if (meta.rev == 0) revert ObjectNotFound();
        if (rev != 0 && rev != meta.rev) revert RevisionNotStored();
        return _objects[id].elements;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
        return interfaceId == type(ISet).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function _create(uint64 id, Descriptor memory desc, bytes32[] memory elems, address owner)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        _objects[id] = ObjectData(desc, owner, elems);
        return desc;
    }

    function _upgrade(uint64 id, uint32 kindRev, uint32 setRev) internal returns (Descriptor memory) {
        if (kindRev == 0 && setRev == 0) revert InvalidUpgradeRevision();
        Descriptor storage desc = _objects[id].desc;
        if (kindRev > 0) {
            if (kindRev <= desc.kindRev) revert InvalidKindRevision();
            if (kindRev != _kindRevision(desc.kindId, kindRev)) revert KindRevisionNotFound();
            desc.kindRev = kindRev;
        }
        if (setRev > 0) {
            if (setRev <= desc.setRev) revert InvalidSetRevision();
            if (setRev != _setRevision(desc.setId, setRev)) revert SetRevisionNotFound();
            desc.setRev = setRev;
        }
        desc.rev++;
        return desc;
    }

    function _update(uint64 id, bytes32[] memory elems) internal returns (Descriptor memory) {
        ObjectData storage obj = _objects[id];
        if (obj.desc.rev == 0) revert ObjectNotFound();
        obj.desc.rev++;
        obj.elements = elems;
        return obj.desc;
    }

    function _touch(uint64 id) internal returns (Descriptor memory) {
        ObjectData storage obj = _objects[id];
        if (obj.desc.rev == 0) revert ObjectNotFound();
        obj.desc.rev++;
        return obj.desc;
    }

    function _transfer(uint64 id, address to) internal returns (address from) {
        from = _objects[id].owner;
        if (to != from) {
            _objects[id].owner = to;
        }
    }

    function _sotaOf(uint64 id) internal view returns (Descriptor memory desc, address owner) {
        desc = _objects[id].desc;
        if (desc.rev == 0) revert ObjectNotFound();
        owner = _objects[id].owner;
    }

    function _ownerOf(uint64 id) internal view returns (address) {
        if (_objects[id].desc.rev == 0) revert ObjectNotFound();
        return _objects[id].owner;
    }

    function _decriptorAt(uint64 id, uint32 rev0) internal view returns (Descriptor memory) {
        if (_objects[id].desc.rev == 0) revert ObjectNotFound();
        if (rev0 == 0 || rev0 == _objects[id].desc.rev) return _objects[id].desc;
        revert RevisionNotStored();
    }

    function _revision(uint64 id, uint32 rev0) internal view virtual returns (uint32 rev) {
        uint32 latest = _objects[id].desc.rev;
        if (latest == 0) revert ObjectNotFound();
        if (rev0 > latest) revert RevisionNotFound();
        else if (rev0 > 0) return rev0;
        else return latest;
    }

    function _postCreate(uint64 id, Descriptor memory desc, bytes32[] memory elems, address owner) internal virtual {
        emit Created(id, desc, elems, owner);
    }

    function _postUpgrade(uint64 id, Descriptor memory desc, uint32 kindRev, uint32 setRev) internal virtual {
        kindRev; // slient warnings
        setRev; // slient warnings
        emit Upgraded(id, desc);
    }

    function _postUpdate(uint64 id, Descriptor memory desc, bytes32[] memory elems) internal virtual {
        emit Updated(id, desc, elems);
    }

    function _postTouch(uint64 id, Descriptor memory desc) internal virtual {
        emit Touched(id, desc);
    }

    function _postTransfer(uint64 id, address from, address to) internal virtual {
        emit Transferred(id, from, to);
    }

    function _preCreate(uint64 id0, bytes32[] memory elems, address owner)
        internal
        virtual
        returns (uint64 id, Descriptor memory desc);

    function _kindRevision(uint64 kindId, uint32 kindRev0) internal view virtual returns (uint32);

    function _setRevision(uint64 setId, uint32 setRev0) internal view virtual returns (uint32);

    function _uri() internal view virtual returns (string memory);
}
