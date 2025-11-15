// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

type Info is bytes32;

type MatterHash is bytes32;

struct ValueRef {
    uint16 rev;
    uint48 tok;
    uint64 _reserved;
    uint128 amount;
}

library ValueRefLib {
    function pack(uint48 tok, uint16 rev, uint128 amount) internal pure returns (bytes32) {
        return bytes32((uint256(rev) << 240) | (uint256(tok) << 192) | uint256(amount));
    }

    function pack(ValueRef memory ref) internal pure returns (bytes32) {
        return bytes32(
            (uint256(ref.rev) << 240) | (uint256(ref.tok) << 192) | (uint256(ref._reserved) << 128)
                | uint256(ref.amount)
        );
    }

    function unpack(bytes32 packed) internal pure returns (ValueRef memory ref) {
        uint256 x = uint256(packed);
        ref.rev = uint16(x >> 240);
        ref.tok = uint48(x >> 192);
        ref._reserved = uint64(x >> 128);
        ref.amount = uint128(x);
    }
}

struct UniqueRef {
    uint16 rev;
    uint48 tok;
    uint64 id;
    uint128 amount;
}

library UniqueRefLib {
    function pack(uint48 tok, uint16 rev, uint64 id, uint128 amount) internal pure returns (bytes32) {
        return bytes32((uint256(rev) << 240) | (uint256(tok) << 192) | (uint256(id) << 128) | uint256(amount));
    }

    function pack(UniqueRef memory ref) internal pure returns (bytes32) {
        return
            bytes32(
                (uint256(ref.rev) << 240) | (uint256(ref.tok) << 192) | (uint256(ref.id) << 128) | uint256(ref.amount)
            );
    }

    function unpack(bytes32 packed) internal pure returns (UniqueRef memory ref) {
        uint256 x = uint256(packed);
        ref.rev = uint16(x >> 240);
        ref.tok = uint48(x >> 192);
        ref.id = uint64(x >> 128);
        ref.amount = uint128(x);
    }
}

struct ObjectRef {
    uint64 set;
    uint64 id;
    uint128 _reserved;
}

library ObjectRefLib {
    function pack(uint64 set, uint64 id) internal pure returns (bytes32) {
        return bytes32((uint256(set) << 192) | (uint256(id) << 128));
    }

    function pack(ObjectRef memory ref) internal pure returns (bytes32) {
        return bytes32((uint256(ref.set) << 192) | (uint256(ref.id) << 128) | uint256(ref._reserved));
    }

    function unpack(bytes32 packed) internal pure returns (ObjectRef memory ref) {
        uint256 x = uint256(packed);
        ref.set = uint64(x >> 192);
        ref.id = uint64(x >> 128);
        ref._reserved = uint128(x);
    }
}
