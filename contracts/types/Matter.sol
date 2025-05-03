// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

enum MatterForm {
    None,
    List,
    Table,
    Perm,
    Json,
    Wasm,
    Image,
    Model
}

struct MatterSpec {
    MatterForm form;
    bytes31 mime;
}

type MatterSpecPacked is bytes32;

struct MatterContent {
    MatterSpecPacked spec;
    bytes blob;
}

type MatterHash is bytes32;
