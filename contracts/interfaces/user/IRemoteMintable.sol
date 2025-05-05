// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IRemoteMintable
/// @notice Interface for set contracts that support external object minters
interface IRemoteMintable is IERC165 {
    /**
     * @notice Called by ObjectMinter after payment is collected, before mint is finalized
     * @dev If `id0` is zero, the contract must assign and return a new object ID
     *      If non-zero, the contract must confirm and return the same ID
     * @param operator The sender who initiated the mint
     * @param to The address that will receive the minted object
     * @param id0 Requested object ID (0 = auto-assign)
     * @param context 256-bit packed context (see MintContext.View)
     * @param data Optional user-defined payload for custom behavior
     * @return selector Must return onObjectMint.selector for confirmation
     * @return id Finalized object ID
     */
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        returns (bytes4 selector, uint64 id);

    /**
     * @notice Returns the address of the ObjectMinter
     */
    function objectMinter() external view returns (address);
}

/// @title MintContext
/// @notice Utility library for encoding and decoding packed minting context data.
/// @dev Encodes a 256-bit context used during minting operations.
///      Layout (from MSB to LSB):
///        [uint64 _reserved | uint64 rangeStart | uint64 rangeEnd | uint32 policy | uint32 tag]
library MintContext {
    struct View {
        uint64 _reserved; // bits 192–255
        uint64 rangeStart; // bits 128–191
        uint64 rangeEnd; // bits 64–127
        uint32 policy; // bits 32–63
        uint32 tag; // bits 0–31
    }

    function pack(View memory v) internal pure returns (uint256 packed) {
        return (uint256(v._reserved) << 192) | (uint256(v.rangeStart) << 128) | (uint256(v.rangeEnd) << 64)
            | (uint256(v.policy) << 32) | uint256(v.tag);
    }

    function pack(uint32 policy, uint32 tag, uint64 rangeStart, uint64 rangeEnd)
        internal
        pure
        returns (uint256 packed)
    {
        return (uint256(0) << 192) | (uint256(rangeStart) << 128) | (uint256(rangeEnd) << 64) | (uint256(policy) << 32)
            | uint256(tag);
    }

    function unpack(uint256 packed) internal pure returns (View memory v) {
        v._reserved = uint64(packed >> 192);
        v.rangeStart = uint64(packed >> 128);
        v.rangeEnd = uint64(packed >> 64);
        v.policy = uint32(packed >> 32);
        v.tag = uint32(packed);
    }
}
