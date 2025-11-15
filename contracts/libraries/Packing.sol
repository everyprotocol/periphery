// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Packing {
    /// @notice Packs up to 16 uint8 values into a single bytes32. Unfilled slots are set to 0.
    function pack_uint8x16(uint8[] memory array) internal pure returns (bytes32 packed) {
        uint256 len = array.length > 16 ? 16 : array.length;
        for (uint256 i = 0; i < len; i++) {
            packed |= bytes32(uint256(array[i]) << (248 - i * 8));
        }
    }

    /// @notice Unpacks a bytes32 into uint8 values, stopping at the first zero
    function unpack_uint8x16(bytes32 packed) internal pure returns (uint8[] memory array) {
        uint8[] memory temp = new uint8[](16);
        uint256 count = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint8 val = uint8(uint256(packed >> (248 - i * 8)));
            if (val == 0) break;
            temp[count++] = val;
        }
        assembly {
            mstore(temp, count)
        }
        return temp;
    }

    /// @notice Packs up to 4 uint64 values into a bytes32. Fills missing slots with 0.
    function pack_uint64x4(uint64[] memory array) internal pure returns (bytes32 packed) {
        uint256 len = array.length > 4 ? 4 : array.length;
        for (uint256 i = 0; i < len; i++) {
            packed |= bytes32(uint256(array[i]) << (192 - i * 64));
        }
    }

    /// @notice Unpacks a bytes32 into up to 4 uint64s, skipping zero values
    function unpack_uint64x4(bytes32 packed) internal pure returns (uint64[] memory array) {
        uint64[] memory temp = new uint64[](4);
        uint256 count = 0;
        for (uint256 i = 0; i < 4; i++) {
            uint64 val = uint64(uint256(packed >> (192 - i * 64)));
            if (val == 0) break;
            temp[count++] = val;
        }
        assembly {
            mstore(temp, count)
        }
        return temp;
    }

    /// @notice Packs up to 16 uint64s into 4 bytes32 values. Fills missing slots with 0.
    function pack_uint64x16(uint64[] memory array)
        internal
        pure
        returns (bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
    {
        p0 = _pack4(array, 0);
        p1 = _pack4(array, 4);
        p2 = _pack4(array, 8);
        p3 = _pack4(array, 12);
    }

    /// @notice Unpacks 4 bytes32 values into an array of up to 16 uint64s, skipping zero values
    function unpack_uint64x16(bytes32 p0, bytes32 p1, bytes32 p2, bytes32 p3)
        internal
        pure
        returns (uint64[] memory array)
    {
        uint64[] memory temp = new uint64[](16);
        uint256 count = 0;
        count = _unpack4(p0, temp, count);
        count = _unpack4(p1, temp, count);
        count = _unpack4(p2, temp, count);
        count = _unpack4(p3, temp, count);
        assembly {
            mstore(temp, count)
        }
        return temp;
    }

    function _pack4(uint64[] memory a, uint256 offset) private pure returns (bytes32 out) {
        for (uint256 i = 0; i < 4; i++) {
            if (offset + i < a.length) {
                out |= bytes32(uint256(a[offset + i]) << (192 - i * 64));
            }
        }
    }

    function _unpack4(bytes32 b, uint64[] memory a, uint256 offset) private pure returns (uint256 newOffset) {
        newOffset = offset;
        for (uint256 i = 0; i < 4; i++) {
            uint64 val = uint64(uint256(b >> (192 - i * 64)));
            if (val == 0) break;
            a[newOffset++] = val;
        }
    }
}
