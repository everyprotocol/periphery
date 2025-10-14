// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

struct MatterSpec {
    uint8 form;
    bytes31 mime;
}

struct MatterContent {
    uint8 form;
    bytes31 mime;
    bytes blob;
}
