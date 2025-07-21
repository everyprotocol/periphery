// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC165} from "../external/IERC165.sol";

/// @title IObjectMinterHook
/// @notice Interface for set contracts that support minting via ObjectMinter
interface IObjectMinterHook is IERC165 {
    /// @notice Called by ObjectMinter after payment is collected and before minting is finalized
    /// @dev
    /// - If `id0` is 0, the contract must assign and return a new object ID.
    /// - If `id0` is non-zero, the contract must validate and return the same ID.
    /// The call must return `onObjectMint.selector` to signal success.
    /// @param operator Caller who initiated the mint (typically msg.sender)
    /// @param to Recipient of the minted object
    /// @param id0 Requested object ID (0 = auto-assign)
    /// @param context Packed 256-bit context for custom mint logic (see MintingContext)
    /// @param data Arbitrary input payload for extensible logic
    /// @return selector Must return `onObjectMint.selector` to proceed
    /// @return id Final resolved object ID to be minted
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        returns (bytes4 selector, uint64 id);
}
