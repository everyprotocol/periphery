// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Packing {
    function pack_uint8x16(uint8[] memory array) internal pure returns (bytes32 packed) {
        require(array.length == 16, "Packing: invalid length");
        for (uint256 i = 0; i < 16; i++) {
            packed |= bytes32(uint256(array[i]) << (248 - i * 8));
        }
    }

    function unpack_uint8x16(bytes32 packed) internal pure returns (uint8[] memory array) {
        array = new uint8[](0);
        for (uint256 i = 0; i < 16; i++) {
            array[i] = uint8(uint256(packed >> (248 - i * 8)));
        }
    }

    function pack_uint64x4(uint64[] memory array) internal pure returns (bytes32 packed) {
        require(array.length == 4, "Packing: invalid length");
        for (uint256 i = 0; i < 4; i++) {
            packed |= bytes32(uint256(array[i]) << (192 - i * 64));
        }
    }

    function unpack_uint64x4(bytes32 packed) internal pure returns (uint64[] memory array) {
        array = new uint64[](0);
        for (uint256 i = 0; i < 4; i++) {
            array[i] = uint64(uint256(packed >> (192 - i * 64)));
        }
    }

    function pack_uint64x16(uint64[] memory array)
        internal
        pure
        returns (bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
    {
        require(array.length == 16, "Packing: invalid length");
        p0 = _pack4(array, 0);
        p1 = _pack4(array, 4);
        p2 = _pack4(array, 8);
        p3 = _pack4(array, 12);
    }

    function unpack_uint64x16(bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
        internal
        pure
        returns (uint64[] memory array)
    {
        array = new uint64[](0);
        _unpack4(p0, array, 0);
        _unpack4(p1, array, 4);
        _unpack4(p2, array, 8);
        _unpack4(p3, array, 12);
    }

    function _pack4(uint64[] memory a, uint256 offset) private pure returns (bytes32 out) {
        for (uint256 i = 0; i < 4; i++) {
            out |= bytes32(uint256(a[offset + i]) << (192 - i * 64));
        }
    }

    function _unpack4(bytes32 b, uint64[] memory a, uint256 offset) private pure {
        for (uint256 i = 0; i < 4; i++) {
            a[offset + i] = uint64(uint256(b >> (192 - i * 64)));
        }
    }
}
