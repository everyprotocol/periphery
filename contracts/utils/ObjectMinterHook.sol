// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC165, IObjectMinterHook} from "../interfaces/user/IObjectMinterHook.sol";
import {ZeroObjectMinter} from "./Errors.sol";
import {SetComposable} from "./SetComposable.sol";

/// @title ObjectMinterHook
/// @notice Base contract for integrating with an external ObjectMinter.
/// @dev Implements the IObjectMinterHook interface and enforces that only the configured ObjectMinter
///      can trigger the minting logic. Inheriting contracts must implement `_mint(...)`.
abstract contract ObjectMinterHook is IObjectMinterHook {
    error NotObjectMinter();

    // forge-lint: disable-next-line(mixed-case-function)
    function _ObjectMinterHook_initialize(address objectMinter) internal {
        if (objectMinter == address(0)) revert ZeroObjectMinter();
        SetComposable.putObjectMinter(objectMinter);
    }

    /// @dev Restricts function to be called only by the configured ObjectMinter.
    modifier onlyObjectMinter() {
        _onlyObjectMinter();
        _;
    }

    /// @inheritdoc IObjectMinterHook
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        override
        onlyObjectMinter
        returns (bytes4 supported, uint64 id)
    {
        id = _mint(operator, to, id0, context, data);
        supported = this.onObjectMint.selector;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool supported) {
        return _ObjectMinterHook_supportsInterface(interfaceId);
    }

    function _onlyObjectMinter() internal view {
        if (msg.sender != SetComposable.getObjectMinter()) revert NotObjectMinter();
    }

    // forge-lint: disable-next-line(mixed-case-function)
    function _ObjectMinterHook_supportsInterface(bytes4 interfaceId) internal pure returns (bool supported) {
        return interfaceId == type(IObjectMinterHook).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @notice Performs the actual minting logic.
    /// @dev Must be implemented by the inheriting contract. The function should resolve and return a valid object ID.
    /// @param operator The address that initiated the mint (typically msg.sender).
    /// @param to The recipient address of the newly minted object.
    /// @param id0 Requested object ID (0 = assign automatically).
    /// @param context Packed context data for the minting operation.
    /// @param data Arbitrary user-defined input passed through the mint call.
    /// @return id The resolved and finalized object ID to be minted.
    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        returns (uint64 id);
}
