// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISet} from "../interfaces/user/ISet.sol";

abstract contract SetSolo is ISet {
    error InvalidObjectId();
    error NotObjectOwner();

    error NoUpgradeTarget();
    error KindRevisionTooLow();
    error SetRevisionTooLow();
    error KindRevisionTooHigh();
    error SetRevisionTooHigh();

    error ObjectExists();
    error ObjectNotExist();
    error ObjectRevisionTooHigh();
    error ObjectRevisionNotArchived();

    struct ObjectData {
        Descriptor desc;
        address owner;
        bytes32[] elems;
    }

    uint64 private constant ID_MAX = type(uint64).max - 1;

    mapping(uint64 => ObjectData) internal _objects;

    /// @dev Restricts function to the current object owner.
    modifier onlyObjectOwner(uint64 id) {
        _onlyObjectOwner(id);
        _;
    }

    /// @inheritdoc ISet
    function upgrade(uint64 id, uint32 krev0, uint32 srev0)
        external
        virtual
        override
        onlyObjectOwner(id)
        returns (Descriptor memory desc)
    {
        desc = _upgrade(id, krev0, srev0);
        _postUpgrade(id, desc, krev0, srev0);
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
        _postTransfer(id, _descriptor(id, 0), from, to);
    }

    /// @inheritdoc ISet
    function uri() external view override returns (string memory uri_) {
        uri_ = _objectURI();
    }

    /// @inheritdoc ISet
    function owner(uint64 id) external view override returns (address owner_) {
        owner_ = _owner(id);
    }

    /// @inheritdoc ISet
    function descriptor(uint64 id, uint32 rev0) external view override returns (Descriptor memory od) {
        od = _descriptor(id, rev0);
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
        return _SetSolo_supportsInterface(interfaceId);
    }

    function _onlyObjectOwner(uint64 id) internal view {
        if (_objects[id].desc.rev == 0) revert ObjectNotExist();
        if (_objects[id].owner != msg.sender) revert NotObjectOwner();
    }

    function _create(address to, uint64 id, Descriptor memory od, bytes32[] memory elems)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectExists();
        _objects[id] = ObjectData({desc: od, owner: to, elems: elems});
        return od;
    }

    function _create0(address to, uint64 id, Descriptor memory od) internal returns (Descriptor memory) {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectExists();
        bytes32[] memory elems = new bytes32[](0);
        _objects[id] = ObjectData({desc: od, owner: to, elems: elems});
        return od;
    }

    function _create1(address to, uint64 id, Descriptor memory od, bytes32 elem0) internal returns (Descriptor memory) {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectExists();
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = elem0;
        _objects[id] = ObjectData({desc: od, owner: to, elems: elems});
        return od;
    }

    function _create2(address to, uint64 id, Descriptor memory od, bytes32 elem0, bytes32 elem1)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectExists();
        bytes32[] memory elems = new bytes32[](2);
        elems[0] = elem0;
        elems[1] = elem1;
        _objects[id] = ObjectData({desc: od, owner: to, elems: elems});
        return od;
    }

    function _update(uint64 id, bytes32[] memory elems) internal returns (Descriptor memory) {
        _objects[id].desc.rev++;
        _objects[id].elems = elems;
        return _objects[id].desc;
    }

    function _upgrade(uint64 id, uint32 krev0, uint32 srev0) internal returns (Descriptor memory) {
        if (krev0 == 0 && srev0 == 0) revert NoUpgradeTarget();
        Descriptor storage od = _objects[id].desc;
        if (krev0 > 0) {
            if (krev0 <= od.kindRev) revert KindRevisionTooLow();
            if (krev0 != _checkKindRevision(od.kindId, krev0)) revert KindRevisionTooHigh();
            od.kindRev = krev0;
        }
        if (srev0 > 0) {
            if (srev0 <= od.setRev) revert SetRevisionTooLow();
            if (srev0 != _checkSetRevision(od.setId, srev0)) revert SetRevisionTooHigh();
            od.setRev = srev0;
        }
        od.rev++;
        return od;
    }

    function _touch(uint64 id) internal returns (Descriptor memory) {
        _objects[id].desc.rev++;
        return _objects[id].desc;
    }

    function _transfer(uint64 id, address to) internal returns (address from) {
        from = _objects[id].owner;
        if (to != from) {
            _objects[id].owner = to;
        }
    }

    function _owner(uint64 id) internal view returns (address) {
        ObjectData memory obj = _objects[id];
        if (obj.desc.rev == 0) revert ObjectNotExist();
        return obj.owner;
    }

    function _descriptor(uint64 id, uint32 rev0) internal view returns (Descriptor memory) {
        Descriptor memory od = _objects[id].desc;
        if (od.rev == 0) revert ObjectNotExist();
        if (rev0 > od.rev) revert ObjectRevisionTooHigh();
        if (rev0 != 0 && rev0 != od.rev) revert ObjectRevisionNotArchived();
        return od;
    }

    function _snapshot(uint64 id, uint32 rev0) internal view returns (Descriptor memory od, bytes32[] memory elems) {
        od = _objects[id].desc;
        if (od.rev == 0) revert ObjectNotExist();
        if (rev0 > od.rev) revert ObjectRevisionTooHigh();
        if (rev0 != 0 && rev0 != od.rev) revert ObjectRevisionNotArchived();
        elems = _objects[id].elems;
    }

    function _postCreate(address to, uint64 id, Descriptor memory od, bytes32[] memory elems) internal virtual {
        emit Created(id, od, elems, to);
    }

    function _postUpgrade(uint64 id, Descriptor memory od, uint32 krev0, uint32 srev0) internal virtual {
        (krev0, srev0); // Unused
        emit Upgraded(id, od);
    }

    function _postUpdate(uint64 id, Descriptor memory od, bytes32[] memory elems) internal virtual {
        emit Updated(id, od, elems);
    }

    function _postTouch(uint64 id, Descriptor memory od) internal virtual {
        emit Touched(id, od);
    }

    function _postTransfer(uint64 id, Descriptor memory od, address from, address to) internal virtual {
        emit Transferred(id, od, from, to);
    }

    function _checkKindRevision(uint64 kind, uint32 krev0) internal view virtual returns (uint32) {
        kind; // Unused
        return krev0;
    }

    function _checkSetRevision(uint64 set, uint32 srev0) internal view virtual returns (uint32) {
        set; // Unused
        return srev0;
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _SetSolo_supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return interfaceId == type(ISet).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _objectURI() internal view virtual returns (string memory);
}
