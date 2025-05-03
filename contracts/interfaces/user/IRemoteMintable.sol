// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IRemoteMintable
/// @notice Interface for object-bearing contracts that support minting via an external minter
/// @dev Implemented by set contracts to validate and handle mint logic triggered by ObjectMinter
///      Enables programmable mint behavior, optional ID resolution, and context-based logic
interface IRemoteMintable is IERC165 {
    /**
     * @notice Struct to describe how the packed `context` argument is encoded in onObjectMint
     * @dev This struct is for reference only; it's not used in calldata directly.
     * @dev The `context` argument in `onObjectMint` is a 256-bit value packed as:
     *      [uint64 _reserved | uint64 rangeStart | uint64 rangeEnd | uint32 policy | uint32 tag]
     */
    struct Context {
        uint64 _reserved; // Reserved for future use (or left as 0)
        uint64 rangeStart; // Inclusive start of the mint range
        uint64 rangeEnd; // Exclusive end of the mint range
        uint32 policy; // Index of the mint policy used
        uint32 tag; // Optional tag for custom metadata or behavior
    }

    /**
     * @notice Called by the minter after payment is collected and before the object is finalized
     * @dev If `id` is zero, the set contract is expected to resolve a new object ID and return it as `resolvedId`.
     *      If `id` is non-zero, the contract must return the same `resolvedId`, or revert.
     * @param operator The address that initiated the mint
     * @param to The address that will receive the minted object
     * @param id0 The requested object ID (0 means auto-assign)
     * @param context A 256-bit packed value encoding policy, range, and metadata (see `Context` struct)
     * @param data Optional user-provided data for custom minting behavior
     * @return selector Must return `onObjectMint.selector` to confirm successful execution
     * @return id
     *  The actual object ID that was minted
     */
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        returns (bytes4 selector, uint64 id);

    /**
     * @notice Returns the address of the associated ObjectMinter contract
     */
    function objectMinter() external returns (address);
}
