// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

struct Descriptor {
    uint32 traits;
    uint32 rev;
    uint32 kindRev;
    uint32 setRev;
    uint64 kindId;
    uint64 setId;
}
