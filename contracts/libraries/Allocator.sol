// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error ObjectIdUnexpected();
error ObjectIdMissing();
error ObjectIdTaken();

library ObjectIdAuto {
    struct Storage {
        uint64 used;
    }

    function allocate(Storage storage self, uint64 id0) internal returns (uint64 id) {
        if (id0 != 0) revert ObjectIdUnexpected();
        id = ++self.used;
    }
}

library ObjectIdManual {
    struct Storage {
        mapping(uint64 => bool) used;
    }

    function allocate(Storage storage self, uint64 id0) internal returns (uint64 id) {
        if (id0 == 0) revert ObjectIdMissing();
        if (self.used[id0]) revert ObjectIdTaken();
        self.used[id0] = true;
        return id0;
    }
}
