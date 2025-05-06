// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IRemoteMintable
/// @notice Interface for set contracts that support minting via an external ObjectMinter
interface IRemoteMintable is IERC165 {
    /// @notice Called by ObjectMinter after payment is collected but before finalizing the mint
    /// @dev If `id0` is 0, the contract must assign and return a new object ID.
    ///      If `id0` is non-zero, the contract must validate and return the same ID.
    /// @param operator Address that initiated the mint (typically msg.sender)
    /// @param to Recipient of the newly minted object
    /// @param id0 Requested object ID (0 = assign automatically)
    /// @param context Packed 256-bit context data (see MintingContext)
    /// @param data Optional arbitrary payload passed for custom logic
    /// @return selector Must return `onObjectMint.selector` to confirm success
    /// @return id Finalized object ID to be minted
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        returns (bytes4 selector, uint64 id);

    /// @notice Returns the address of the ObjectMinter contract
    /// @return minter The ObjectMinter address
    function objectMinter() external view returns (address minter);
}
