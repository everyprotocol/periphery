// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISet} from "../interfaces/user/ISet.sol";

// @title SetSolo
/// @notice Minimal standalone implementation of the ISet interface for managing object tokens.
/// @dev Handles object storage, ownership, versioning, and upgrade logic. Intended to be extended by full set contracts.
abstract contract SetSolo is ISet {
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
    error Unimplemented();

    struct ObjectData {
        Descriptor desc;
        address owner;
        bytes32[] elements;
    }

    uint64 private constant ID_MAX = type(uint64).max - 1;

    mapping(uint64 => ObjectData) internal _objects;

    /// @dev Restricts function to the current object owner.
    modifier onlyObjectOwner(uint64 id) {
        if (_objects[id].desc.rev == 0) revert ObjectNotFound();
        if (_objects[id].owner != msg.sender) revert CallerNotObjectOwner();
        _;
    }

    /// @inheritdoc ISet
    function create(address to, uint64 id0, bytes calldata data)
        external
        virtual
        returns (uint64 id, Descriptor memory od)
    {
        (to, id0, data, id, od); // silient warnings;
        revert Unimplemented();
    }

    /// @inheritdoc ISet
    function update(uint64 id, bytes calldata data) external virtual returns (Descriptor memory od) {
        (id, data, od); // silient warnings;
        revert Unimplemented();
    }

    /// @inheritdoc ISet
    function upgrade(uint64 id, uint32 kindRev0, uint32 setRev0)
        external
        virtual
        override
        onlyObjectOwner(id)
        returns (Descriptor memory desc)
    {
        desc = _upgrade(id, kindRev0, setRev0);
        _postUpgrade(id, desc, kindRev0, setRev0);
        return desc;
    }

    /// @inheritdoc ISet
    function touch(uint64 id) external virtual override onlyObjectOwner(id) returns (Descriptor memory od) {
        od = _touch(id);
        _postTouch(id, od);
        return od;
    }

    /// @inheritdoc ISet
    function transfer(uint64 id, address to) external virtual override onlyObjectOwner(id) {
        address from = _transfer(id, to);
        _postTransfer(id, from, to);
    }

    /// @inheritdoc ISet
    function uri() external view override returns (string memory uri_) {
        uri_ = _uri();
    }

    /// @inheritdoc ISet
    function owner(uint64 id) external view override returns (address owner_) {
        owner_ = _owner(id);
    }

    /// @inheritdoc ISet
    function descriptor(uint64 id, uint32 rev0) external view override returns (Descriptor memory od) {
        od = _decriptor(id, rev0);
    }

    /// @inheritdoc ISet
    function snapshot(uint64 id, uint32 rev0)
        external
        view
        override
        returns (Descriptor memory od, bytes32[] memory elems)
    {
        (od, elems) = _snapshot(id, rev0);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool) {
        return interfaceId == type(ISet).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function _create(uint64 id, Descriptor memory od, bytes32[] memory elems, address owner_)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        _objects[id] = ObjectData(od, owner_, elems);
        return od;
    }

    function _update(uint64 id, bytes32[] memory elems) internal returns (Descriptor memory) {
        ObjectData storage obj = _objects[id];
        if (obj.desc.rev == 0) revert ObjectNotFound();
        obj.desc.rev++;
        obj.elements = elems;
        return obj.desc;
    }

    function _upgrade(uint64 id, uint32 kindRev0, uint32 setRev0) internal returns (Descriptor memory) {
        if (kindRev0 == 0 && setRev0 == 0) revert InvalidUpgradeRevision();
        Descriptor storage od = _objects[id].desc;
        if (kindRev0 > 0) {
            if (kindRev0 <= od.kindRev) revert InvalidKindRevision();
            if (kindRev0 != _resolveKindRev(od.kindId, kindRev0)) revert KindRevisionNotFound();
            od.kindRev = kindRev0;
        }
        if (setRev0 > 0) {
            if (setRev0 <= od.setRev) revert InvalidSetRevision();
            if (setRev0 != _resolveSetRev(od.setId, setRev0)) revert SetRevisionNotFound();
            od.setRev = setRev0;
        }
        od.rev++;
        return od;
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

    function _owner(uint64 id) internal view returns (address) {
        if (_objects[id].desc.rev == 0) revert ObjectNotFound();
        return _objects[id].owner;
    }

    function _decriptor(uint64 id, uint32 rev0) internal view returns (Descriptor memory) {
        Descriptor memory od = _objects[id].desc;
        if (od.rev == 0) revert ObjectNotFound();
        if (rev0 != 0 && rev0 != od.rev) revert RevisionNotStored();
        return od;
    }

    function _snapshot(uint64 id, uint32 rev0) internal view returns (Descriptor memory od, bytes32[] memory elems) {
        od = _objects[id].desc;
        if (od.rev == 0) revert ObjectNotFound();
        if (rev0 != 0 && rev0 != od.rev) revert RevisionNotStored();
        elems = _objects[id].elements;
    }

    function _postCreate(uint64 id, Descriptor memory od, bytes32[] memory elems, address owner_) internal virtual {
        emit Created(id, od, elems, owner_);
    }

    function _postUpgrade(uint64 id, Descriptor memory od, uint32 kindRev0, uint32 setRev0) internal virtual {
        (kindRev0, setRev0); // Unused
        emit Upgraded(id, od);
    }

    function _postUpdate(uint64 id, Descriptor memory od, bytes32[] memory elems) internal virtual {
        emit Updated(id, od, elems);
    }

    function _postTouch(uint64 id, Descriptor memory od) internal virtual {
        emit Touched(id, od);
    }

    function _postTransfer(uint64 id, address from, address to) internal virtual {
        emit Transferred(id, from, to);
    }

    function _uri() internal view virtual returns (string memory);

    function _resolveKindRev(uint64 kindId, uint32 kindRev0) internal view virtual returns (uint32);

    function _resolveSetRev(uint64 setId, uint32 setRev0) internal view virtual returns (uint32);
}
