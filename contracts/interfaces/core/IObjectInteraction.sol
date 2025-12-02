// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/// @title IObjectInteraction
/// @notice Handles object interactions via directed relations (arcs).
interface IObjectInteraction {
    /// @notice Emitted when a tail is linked to a head through a relation
    /// @param head Encoded SID of the head object
    /// @param desc Descriptor of the head after the relation
    /// @param arc Encoded incoming arc
    event Related(uint128 head, Descriptor desc, uint256 arc);

    /// @notice Emitted when multiple tails are linked to a head
    /// @param head Encoded SID of the head object
    /// @param desc Descriptor of the head after the relations
    /// @param arcs Array of encoded incoming arcs
    event Related(uint128 head, Descriptor desc, uint256[] arcs);

    /// @notice Emitted when a tail is unlinked from a head
    /// @param head Encoded SID of the head object
    /// @param desc Descriptor of the head after unlinking
    /// @param arc Encoded incoming arc
    event Unrelated(uint128 head, Descriptor desc, uint256 arc);

    /// @notice Emitted when multiple tails are unlinked from a head
    /// @param head Encoded SID of the head object
    /// @param desc Descriptor of the head after unlinking
    /// @param arcs Array of encoded incoming arcs
    event Unrelated(uint128 head, Descriptor desc, uint256[] arcs);

    /// @notice Links a tail object to a head object through a relation
    /// @param tail Encoded tail node
    /// @param rel Relation ID
    /// @param head Encoded head node
    function relate(uint256 tail, uint64 rel, uint256 head) external;

    /// @notice Unlinks a tail object from a head object
    /// @param tail Encoded tail node
    /// @param rel Relation ID
    /// @param head Encoded head node
    function unrelate(uint256 tail, uint64 rel, uint256 head) external;
}
