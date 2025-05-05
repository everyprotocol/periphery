// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IInteroperable
/// @notice Interface for set contracts that support object-level interoperability
/// @dev Enables a set to react to registry lifecycle events and object interactions.
///      These callbacks are invoked *before* the respective action is finalized.
///      The protocol requires that the callback returns the expected value for the action to proceed.
interface IInteroperable is IERC165 {
    // ------------------------
    // Set Management Callbacks
    // ------------------------

    /**
     * @notice Called before a set is registered
     * @param set Set ID
     * @param od Descriptor of the set
     * @return selector Must return onSetRegister.selector
     */
    function onSetRegister(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /**
     * @notice Called before a set is updated
     * @param set Set ID
     * @param od Updated descriptor
     * @return selector Must return onSetUpdate.selector
     */
    function onSetUpdate(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /**
     * @notice Called before a set is upgraded
     * @param set Set ID
     * @param od Descriptor after upgrade
     * @return selector Must return onSetUpgrade.selector
     */
    function onSetUpgrade(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    /**
     * @notice Called before a set is touched (revision bump with no content change)
     * @param set Set ID
     * @param od Descriptor after touch
     * @return selector Must return onSetTouch.selector
     */
    function onSetTouch(uint64 set, Descriptor memory od) external returns (bytes4 selector);

    // ----------------------------
    // Object Interaction Callbacks
    // ----------------------------

    /**
     * @notice Called before an object from this set is linked to another object
     * @param id Head object ID (belongs to this set)
     * @param rel Relation ID
     * @param data Optional relation data (uint64 encoded)
     * @param tailSet Set ID of the tail object
     * @param tailId ID of the tail object
     * @param tailKind Kind ID of the tail object
     * @return od Updated descriptor of the head object
     */
    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory od);

    /**
     * @notice Called before an object from this set is unlinked from another object
     * @param id Head object ID (belongs to this set)
     * @param rel Relation ID
     * @param data Optional relation data (uint64 encoded)
     * @param tailSet Set ID of the tail object
     * @param tailId ID of the tail object
     * @param tailKind Kind ID of the tail object
     * @return od Updated descriptor of the head object
     */
    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        returns (Descriptor memory od);

    /**
     * @notice Called before ownership of an object from this set is transferred
     *         as part of a relation or unrelation operation.
     * @param id ID of the object being transferred
     * @param from Current owner
     * @param to New owner
     * @return selector Must return onObjectTransfer.selector to proceed
     */
    function onObjectTransfer(uint64 id, address from, address to) external returns (bytes4 selector);
}
