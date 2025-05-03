// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

struct Descriptor {
    uint32 traits; // Traits or flags of the object
    uint32 rev; // Current revision of the object itself
    uint32 kindRev; // Revision of the object's kind
    uint32 setRev; // Revision of the object's set
    uint64 kindId; //Id of the object's kind
    uint64 setId; // Id of the object's set
}

type DescriptorPacked is bytes32;

using DescriptorLib for DescriptorPacked global;

library DescriptorLib {
    function pack(Descriptor memory d) internal pure returns (DescriptorPacked) {
        return DescriptorPacked.wrap(
            bytes32(
                (uint256(d.traits)) | (uint256(d.rev) << 32) | (uint256(d.kindRev) << 64) | (uint256(d.setRev) << 96)
                    | (uint256(d.kindId) << 128) | (uint256(d.setId) << 192)
            )
        );
    }

    function unpack(DescriptorPacked packed) internal pure returns (Descriptor memory d) {
        uint256 raw = uint256(DescriptorPacked.unwrap(packed));
        d.traits = uint32(raw);
        d.rev = uint32(raw >> 32);
        d.kindRev = uint32(raw >> 64);
        d.setRev = uint32(raw >> 96);
        d.kindId = uint64(raw >> 128);
        d.setId = uint64(raw >> 192);
    }

    function traits(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)));
    }

    function rev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 32);
    }

    function kindRev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 64);
    }

    function setRev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 96);
    }

    function kindId(DescriptorPacked packed) internal pure returns (uint64) {
        return uint64(uint256(DescriptorPacked.unwrap(packed)) >> 128);
    }

    function setId(DescriptorPacked packed) internal pure returns (uint64) {
        return uint64(uint256(DescriptorPacked.unwrap(packed)) >> 192);
    }
}
