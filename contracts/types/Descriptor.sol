// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

struct Descriptor {
    uint32 traits; // bits 224–255
    uint32 rev; // bits 192–223
    uint32 kindRev; // bits 160–191
    uint32 setRev; // bits 128–159
    uint64 kindId; // bits 64–127
    uint64 setId; // bits 0–63
}

type DescriptorPacked is bytes32;

library DescriptorLib {
    function pack(Descriptor memory d) internal pure returns (DescriptorPacked) {
        return DescriptorPacked.wrap(
            bytes32(
                (uint256(d.traits) << 224) | (uint256(d.rev) << 192) | (uint256(d.kindRev) << 160)
                    | (uint256(d.setRev) << 128) | (uint256(d.kindId) << 64) | uint256(d.setId)
            )
        );
    }

    function unpack(DescriptorPacked packed) internal pure returns (Descriptor memory d) {
        uint256 raw = uint256(DescriptorPacked.unwrap(packed));
        d.traits = uint32(raw >> 224);
        d.rev = uint32(raw >> 192);
        d.kindRev = uint32(raw >> 160);
        d.setRev = uint32(raw >> 128);
        d.kindId = uint64(raw >> 64);
        d.setId = uint64(raw);
    }

    function traits(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 224);
    }

    function rev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 192);
    }

    function kindRev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 160);
    }

    function setRev(DescriptorPacked packed) internal pure returns (uint32) {
        return uint32(uint256(DescriptorPacked.unwrap(packed)) >> 128);
    }

    function kindId(DescriptorPacked packed) internal pure returns (uint64) {
        return uint64(uint256(DescriptorPacked.unwrap(packed)) >> 64);
    }

    function setId(DescriptorPacked packed) internal pure returns (uint64) {
        return uint64(uint256(DescriptorPacked.unwrap(packed)));
    }
}
