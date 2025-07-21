// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "../external/IERC165.sol";

/// @title IInteroperable
/// @notice Interface for set contracts that support object-level interoperability
/// @dev Enables a set to respond to interactions involving its objects. These hooks are called *before* the action is finalized.
/// Returning the expected value is required for the operation to proceed.
interface IInteroperable is IERC165 {
    /// @notice Hook called before an object from this set is linked to another object
    /// @param id Object ID from this set (acts as the head)
    /// @param rel Relation ID
    /// @param data Encoded relation-specific data (optional, uint64)
    /// @param tailSet Set ID of the tail object
    /// @param tailId Object ID of the tail
    /// @param tailKind Kind ID of the tail object
    /// @return od Updated descriptor of the head object
    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory od);

    /// @notice Hook called before an object from this set is unlinked from another object
    /// @param id Object ID from this set (acts as the head)
    /// @param rel Relation ID
    /// @param data Encoded relation-specific data (optional, uint64)
    /// @param tailSet Set ID of the tail object
    /// @param tailId Object ID of the tail
    /// @param tailKind Kind ID of the tail object
    /// @return od Updated descriptor of the head object
    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory od);

    /// @notice Hook called before ownership of an object from this set is transferred as part of a relation or unrelation
    /// @param id Object ID being transferred
    /// @param from Current owner address
    /// @param to New owner address
    /// @return selector Must return `onObjectTransfer.selector` to confirm and proceed
    function onObjectTransfer(uint64 id, address from, address to) external returns (bytes4 selector);
}
