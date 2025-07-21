// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {MintPolicy} from "../../types/Minter.sol";

/// @title IObjectMinter
/// @notice Interface for minting objects with configurable policies
interface IObjectMinter {
    // --- Events ---

    /// @notice Emitted when a mint policy is enabled
    /// @param set The set address the policy applies to
    /// @param policy The enabled policy details
    event MintPolicyEnabled(address set, MintPolicy policy);

    /// @notice Emitted when a mint policy is disabled
    /// @param set The set address the policy applies to
    /// @param policy The disabled policy details
    event MintPolicyDisabled(address set, MintPolicy policy);

    /// @notice Emitted when an object is successfully minted
    /// @param set The address of the set contract the object is minted from
    /// @param id The ID of the minted object within the set
    /// @param operator The address that initiated the mint (usually msg.sender)
    /// @param to The recipient address receiving the minted object
    /// @param currency The address of the payment token (native or ERC20)
    /// @param payment The total payment (includes both fee and funds)
    /// @param fundsRecipient The address receiving the creator or project revenue
    /// @param funds The amount sent to the fundsRecipient
    /// @param feeRecipient The address receiving the protocol fee
    /// @param fee The amount sent to the feeRecipient
    event ObjectMinted(
        address set,
        uint64 id,
        address operator,
        address to,
        address currency,
        uint96 payment,
        address fundsRecipient,
        uint96 funds,
        address feeRecipient,
        uint96 fee
    );

    // --- Write Methods for Collectors ---

    /// @notice Mint an object (public permission)
    /// @param set The set address
    /// @param id The object ID to mint
    /// @param to The recipient address
    function mint(address to, address set, uint64 id) external payable;

    /// @notice Mint an object with additional data
    /// @param set The set address
    /// @param id The object ID to mint
    /// @param to The recipient address
    /// @param data Additional mint data
    function mint(address to, address set, uint64 id, bytes memory data) external payable;

    /// @notice Mint an object with allowlist proof
    /// @param set The set address
    /// @param id The object ID to mint
    /// @param to The recipient address
    /// @param auth ABI-encoded authorization data (see IMintAuthArgument)
    /// @param policy The policy index being used
    function mint(address to, address set, uint64 id, bytes memory auth, uint32 policy) external payable;

    /// @notice Mint an object with allowlist proof and additional data
    /// @param set The set address
    /// @param id The object ID to mint
    /// @param to The recipient address
    /// @param data Additional mint data
    /// @param auth ABI-encoded authorization data (see IMintAuthArgument)
    /// @param policy The policy index being used
    function mint(address to, address set, uint64 id, bytes memory data, bytes memory auth, uint32 policy)
        external
        payable;

    // --- Write Methods for Set Contracts ---

    /// @notice Add a new mint policy (callable only by set contracts)
    /// @param policy The policy details to add
    /// @return index The assigned policy index
    function mintPolicyAdd(MintPolicy memory policy) external returns (uint32 index);

    /// @notice Disable a mint policy (callable only by set contracts)
    /// @param index The policy index to disable
    function mintPolicyDisable(uint32 index) external;

    /// @notice Enable a mint policy (callable only by set contracts)
    /// @param index The policy index to enable
    function mintPolicyEnable(uint32 index) external;

    // --- View Methods ---

    /// @notice Get number of mint policies for a set
    /// @param set The set address to query
    /// @return count Number of policies
    function mintPolicyCount(address set) external view returns (uint256 count);

    /// @notice Get mint policy by index
    /// @param set The set address
    /// @param index Policy index
    /// @return policy The mint policy details
    function mintPolicyGet(address set, uint32 index) external view returns (MintPolicy memory policy);

    /// @notice Search for applicable mint policy with permission mask
    /// @param set The set address
    /// @param id The object ID to check
    /// @param mask Bitmask indicating which MintPermissionType values are included.
    ///             Each bit corresponds to a permission type (e.g., bit 0 = Public, bit 1 = Allowlist, etc.).
    /// @return policy The first matching mint policy
    function mintPolicySearch(address set, uint64 id, uint8 mask) external view returns (MintPolicy memory policy);

    /// @notice Search for applicable mint policy with offset and permission mask
    /// @param set The set address
    /// @param id The object ID to check
    /// @param offset Starting policy index to search from
    /// @param mask Bitmask indicating which MintPermissionType values are included.
    ///             Each bit corresponds to a permission type (e.g., bit 0 = Public, bit 1 = Allowlist, etc.).
    /// @return policy The first matching mint policy
    function mintPolicySearch(address set, uint64 id, uint8 mask, uint32 offset)
        external
        view
        returns (MintPolicy memory policy);
}
