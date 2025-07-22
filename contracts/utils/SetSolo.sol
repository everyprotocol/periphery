// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, IERC165, ISet} from "../interfaces/user/ISet.sol";
import {SetContext} from "@everyprotocol/periphery/utils/SetContext.sol";

// @title SetSolo
/// @notice Minimal standalone implementation of the ISet interface for managing object tokens.
/// @dev Handles object storage, ownership, versioning, and upgrade logic. Intended to be extended by full set contracts.
abstract contract SetSolo is ISet {
    error CallerNotObjectOwner();
    error InvalidObjectId();
    error UnknownObjectKind();
    error UnknownObjectSet();
    error InvalidKindRevision();
    error InvalidSetRevision();
    error InvalidUpgradeArguments();
    error ObjectAlreadyExists();
    error ObjectNotFound();
    error RevisionNotStored();
    error RevisionNotFound();
    error KindUpgradeRejected();
    error SetUpgradeRejected();
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
        uri_ = _objectURI();
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
        return _supportsInterface(interfaceId);
    }

    function _supportsInterface(bytes4 interfaceId) internal pure virtual returns (bool) {
        return interfaceId == type(ISet).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function _create(address to, uint64 id, Descriptor memory od, bytes32[] memory elems)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        _objects[id] = ObjectData(od, to, elems);
        return od;
    }

    function _create0(address to, uint64 id, Descriptor memory od) internal returns (Descriptor memory) {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        bytes32[] memory elems = new bytes32[](0);
        _objects[id] = ObjectData(od, to, elems);
        return od;
    }

    function _create1(address to, uint64 id, Descriptor memory od, bytes32 elem0)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = elem0;
        _objects[id] = ObjectData(od, to, elems);
        return od;
    }

    function _create2(address to, uint64 id, Descriptor memory od, bytes32 elem0, bytes32 elem1)
        internal
        returns (Descriptor memory)
    {
        if (id == 0 || id >= ID_MAX) revert InvalidObjectId();
        if (_objects[id].desc.rev != 0) revert ObjectAlreadyExists();
        bytes32[] memory elems = new bytes32[](2);
        elems[0] = elem0;
        elems[1] = elem1;
        _objects[id] = ObjectData(od, to, elems);
        return od;
    }

    function _update(uint64 id, bytes32[] memory elems) internal returns (Descriptor memory) {
        _objects[id].desc.rev++;
        _objects[id].elements = elems;
        return _objects[id].desc;
    }

    function _upgrade(uint64 id, uint32 kindRev0, uint32 setRev0) internal returns (Descriptor memory) {
        if (kindRev0 == 0 && setRev0 == 0) revert InvalidUpgradeArguments();
        Descriptor storage od = _objects[id].desc;
        if (kindRev0 > 0) {
            if (kindRev0 <= od.kindRev) revert InvalidKindRevision();
            if (kindRev0 != _onUpgradeKind(od.kindId, kindRev0)) revert KindUpgradeRejected();
            od.kindRev = kindRev0;
        }
        if (setRev0 > 0) {
            if (setRev0 <= od.setRev) revert InvalidSetRevision();
            if (setRev0 != _onUpgradeSet(od.setId, setRev0)) revert SetUpgradeRejected();
            od.setRev = setRev0;
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
        if (obj.desc.rev == 0) revert ObjectNotFound();
        return obj.owner;
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

    function _postCreate(address to, uint64 id, Descriptor memory od, bytes32[] memory elems) internal virtual {
        emit Created(id, od, elems, to);
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

    function _onUpgradeKind(uint64 kindId, uint32 kindRev0) internal view virtual returns (uint32) {
        if (kindId != SetContext.getKindId()) revert UnknownObjectKind();
        uint32 kindRev = SetContext.getKindRev();
        if (kindRev0 == 0) {
            return kindRev;
        } else if (kindRev0 <= kindRev) {
            return kindRev0;
        } else {
            return 0;
        }
    }

    function _onUpgradeSet(uint64 setId, uint32 setRev0) internal view virtual returns (uint32) {
        if (setId != SetContext.getSetId()) revert UnknownObjectSet();
        uint32 setRev = SetContext.getSetRev();
        if (setRev0 == 0) {
            return setRev;
        } else if (setRev0 <= setRev) {
            return setRev0;
        } else {
            return 0;
        }
    }

    function _objectURI() internal view virtual returns (string memory);
}
