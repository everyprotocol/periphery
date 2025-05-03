// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Constraints} from "../constants/Constraints.sol";
import {Revisions} from "../constants/Revisions.sol";
import {Semver} from "../libraries/Semver.sol";
import {Descriptor} from "../types/Descriptor.sol";

/**
 * @title Snapshots
 * @dev Library for storing object revisions
 */
library Snapshots {
    error InvalidId();
    error InvalidOwner();
    error InvalidKindId();
    error InvalidSetId();
    error InvalidRevision();
    error InvalidKindRevision();
    error InvalidSetRevision();
    error InvalidElements();
    error InvalidField();
    error RecordExists(uint64 id);
    error RecordNotExist(uint64 id);
    error RecordNotActive(uint64 id);
    error RevisionNotExist(uint64 id, uint32 rev);
    error Unauthorized(uint64 id, address visitor);

    /// @notice Object record tracking ownership and latest revision
    struct Status {
        address owner;
        uint32 latest;
    }

    /// @notice Revision record containing descriptor and elements
    struct Revision {
        Descriptor desc;
        bytes32[16] elems;
    }

    struct Storage {
        mapping(uint256 => Status) sota; // state of the art
        mapping(uint256 => Revision) revisions; // revisions
    }

    function semver() external pure returns (uint32 version) {
        version = Semver.pack(0, 0, 1, 0);
    }

    // --- Create ---

    function create(Storage storage $, uint64 id, Descriptor memory desc, bytes32[] memory elems, address owner)
        external
    {
        if (owner == address(0)) revert InvalidOwner();
        if ($.sota[id].latest != 0) revert RecordExists(id);
        if (elems.length > Constraints.MAX_KIND_ELEMENTS) revert InvalidElements();

        _validateDescriptor(desc);

        Revision storage revision = $.revisions[_makeRevisionKey(id, desc.rev)];
        revision.desc = desc;
        for (uint256 i = 0; i < elems.length; i++) {
            revision.elems[i] = elems[i];
        }

        $.sota[id] = Status(owner, desc.rev);
    }

    // --- Update ---

    function update(Storage storage $, uint64 id, bytes32[] memory elems) external returns (Descriptor memory) {
        if (elems.length > Constraints.MAX_KIND_ELEMENTS) revert InvalidElements();

        Status storage status = $.sota[id];
        if (status.latest == 0) revert RecordNotExist(id);

        Revision memory prev = $.revisions[_makeRevisionKey(id, status.latest)];
        Descriptor memory desc = prev.desc;
        desc.rev++;

        Revision storage revision = $.revisions[_makeRevisionKey(id, desc.rev)];
        revision.desc = desc;
        for (uint256 i = 0; i < elems.length; i++) {
            revision.elems[i] = elems[i];
        }

        status.latest = desc.rev;
        return desc;
    }

    // --- upgrade ---

    function upgrade(Storage storage $, uint64 id, uint32 kindRev, uint32 setRev, uint256 count)
        external
        returns (Descriptor memory)
    {
        Status storage status = $.sota[id];
        if (status.latest == 0) revert RecordNotExist(id);

        Revision memory prev = $.revisions[_makeRevisionKey(id, status.latest)];
        Descriptor memory desc = prev.desc;
        if (kindRev < desc.kindRev) revert InvalidKindRevision();
        if (setRev < desc.setRev) revert InvalidSetRevision();

        // new meta
        desc.kindRev = kindRev;
        desc.setRev = setRev;
        desc.rev++;
        Revision storage revision = $.revisions[_makeRevisionKey(id, desc.rev)];
        revision.desc = desc;
        for (uint256 i = 0; i < count; i++) {
            revision.elems[i] = prev.elems[i];
        }

        status.latest = desc.rev;
        return desc;
    }

    // --- touch ---

    function touch(Storage storage $, uint64 id, uint256 count) external returns (Descriptor memory) {
        Status storage status = $.sota[id];
        if (status.latest == 0) revert RecordNotExist(id);

        Revision memory prev = $.revisions[_makeRevisionKey(id, status.latest)];
        Descriptor memory desc = prev.desc;
        desc.rev++;
        Revision storage revision = $.revisions[_makeRevisionKey(id, desc.rev)];
        revision.desc = desc;
        for (uint256 i = 0; i < count; i++) {
            revision.elems[i] = prev.elems[i];
        }

        status.latest = desc.rev;
        return desc;
    }

    // --- transfer ---

    function transfer(Storage storage $, uint64 id, address to) external returns (address from) {
        Status storage status = $.sota[id];
        if (status.latest == 0) revert RecordNotExist(id);
        from = status.owner;
        status.owner = to;
    }

    // --- Read ---

    function ownerOf(Storage storage $, uint64 id) external view returns (address) {
        Status memory status = _requireStatus($, id);
        return status.owner;
    }

    function statusOf(Storage storage $, uint64 id) external view returns (uint32) {
        return $.sota[id].latest;
    }

    function statusOf(Storage storage $, uint64[] memory ids) external view returns (bool) {
        for (uint256 i = 0; i < ids.length; i++) {
            if ($.sota[ids[i]].latest == 0) {
                return false;
            }
        }
        return true;
    }

    function descriptorAt(Storage storage $, uint64 id, uint32 rev) external view returns (Descriptor memory) {
        Status memory status = _requireStatus($, id);
        if (rev == 0) {
            rev = status.latest;
        } else if (rev > status.latest) {
            revert RevisionNotExist(id, rev);
        }

        Revision memory revision = $.revisions[_makeRevisionKey(id, rev)];
        return revision.desc;
    }

    function elementsAt(Storage storage $, uint64 id, uint32 rev, uint256 num)
        external
        view
        returns (bytes32[] memory)
    {
        if (num > Constraints.MAX_KIND_ELEMENTS) revert InvalidElements();
        Status memory status = _requireStatus($, id);
        if (rev == 0) {
            rev = status.latest;
        } else if (rev > status.latest) {
            revert RevisionNotExist(id, rev);
        }

        Revision memory revision = $.revisions[_makeRevisionKey(id, rev)];
        bytes32[] memory elems = new bytes32[](num);
        for (uint256 i = 0; i < num; i++) {
            elems[i] = revision.elems[i];
        }
        return elems;
    }

    function fieldAt(Storage storage $, uint64 id, uint32 rev, uint256 index) external view returns (bytes32) {
        if (index >= Constraints.MAX_KIND_ELEMENTS) revert InvalidField();
        Status memory status = _requireStatus($, id);
        if (rev == 0) {
            rev = status.latest;
        } else if (rev > status.latest) {
            revert RevisionNotExist(id, rev);
        }
        return $.revisions[_makeRevisionKey(id, rev)].elems[index];
    }

    function recordAt(Storage storage $, uint64 id, uint32 rev, uint256 num)
        external
        view
        returns (Descriptor memory, bytes32[] memory)
    {
        if (num > Constraints.MAX_KIND_ELEMENTS) revert InvalidElements();

        Status memory status = _requireStatus($, id);
        if (rev == 0) {
            rev = status.latest;
        } else if (rev > status.latest) {
            revert RevisionNotExist(id, rev);
        }
        Revision memory revision = $.revisions[_makeRevisionKey(id, rev)];
        bytes32[] memory elems = new bytes32[](num);
        for (uint256 i = 0; i < num; i++) {
            elems[i] = revision.elems[i];
        }
        return (revision.desc, elems);
    }

    // --- Internals ---

    function _requireStatus(Storage storage $, uint64 id) private view returns (Status memory) {
        Status memory status = $.sota[id];
        if (status.latest == 0) revert RecordNotExist(id);
        return status;
    }

    function _validateDescriptor(Descriptor memory desc) private pure {
        if (desc.rev != Revisions.INITIAL) revert InvalidRevision();
        if (desc.kindRev == 0) revert InvalidKindRevision();
        if (desc.setRev == 0) revert InvalidSetRevision();
        if (desc.kindId == 0) revert InvalidKindId();
        if (desc.setId == 0) revert InvalidSetId();
    }

    function _makeRevisionKey(uint64 id, uint32 rev) private pure returns (uint256) {
        return (uint256(rev) << 64) | uint256(id);
    }
}
