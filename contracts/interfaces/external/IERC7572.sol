// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @title IERC7572 - Contract-level Metadata Extension
/// @notice ERC-7572 standard interface for exposing contract-level metadata via `contractURI()`
/// @dev See https://eips.ethereum.org/EIPS/eip-7572
interface IERC7572 {
    /// @notice Emitted when the contract URI is updated
    event ContractURIUpdated();

    /// @notice Returns a URI pointing to contract-level metadata
    /// @dev The metadata should conform to a standard like OpenSea's contract-level metadata schema
    /// @return uri_ The contract metadata URI as a string
    function contractURI() external view returns (string memory uri_);
}
