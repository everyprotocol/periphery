// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Packing {
    function pack_uint8x16(uint8[] memory array) internal pure returns (bytes32 packed) {}

    function unpack_uint8x16(bytes32 packed) internal pure returns (uint8[] memory array) {}

    function pack_uint64x4(uint64[] memory array) internal pure returns (bytes32 packed) {}

    function unpack_uint64x4(bytes32 packed) internal pure returns (uint64[] memory array) {}

    function pack_uint64x16(uint64[] memory array)
        internal
        pure
        returns (bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
    {}

    function unpack_uint64x16(bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
        internal
        pure
        returns (uint64[] memory array)
    {}
}
