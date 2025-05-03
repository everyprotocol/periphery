// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Semver {
    function pack(uint8 storage_, uint8 major, uint8 minor, uint8 patch) internal pure returns (uint32 semver) {
        semver = (uint32(storage_) << 24) | (uint32(major) << 16) | (uint32(minor) << 8) | uint32(patch);
    }

    function unpack(uint32 semver) internal pure returns (uint8 storage_, uint8 major, uint8 minor, uint8 patch) {
        storage_ = uint8(semver >> 24);
        major = uint8(semver >> 16);
        minor = uint8(semver >> 8);
        patch = uint8(semver);
    }
}
