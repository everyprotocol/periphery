// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";

/**
 * @title IObjectInteraction
 * @notice Manages relation registration and object interactions through relations.
 *
 * ## Encoding
 *
 * | Name      | Type     | Encoding              | Description                            |
 * |-----------|----------|-----------------------|----------------------------------------|
 * | tail,head | uint128  | (set << 64) | id     | Encoded Scoped ID (SID) of an object   |
 * | relx      | uint128  | (data << 64) | rel    | Encoded relation ID with extra data    |
 * | tailx     | uint256  | (relx << 128) | tail  | Encoded tail with relation and data    |
 */
interface IObjectInteraction {
    /**
     * @notice Emitted when a tail is linked to a head through a relation
     * @param head Encoded SID of the head object
     * @param desc Descriptor of the head after the relation
     * @param arc Encoded tail with relation and extra data
     */
    event Related(uint128 head, Descriptor desc, uint256 arc);

    /**
     * @notice Emitted when multiple tails are linked to a head
     * @param head Encoded SID of the head object
     * @param desc Descriptor of the head after the relations
     * @param arcs Array of encoded tails with relation and data
     */
    event Related(uint128 head, Descriptor desc, uint256[] arcs);

    /**
     * @notice Emitted when a tail is unlinked from a head
     * @param head Encoded SID of the head object
     * @param desc Descriptor of the head after unlinking
     * @param arc Encoded tail with relation and extra data
     */
    event Unrelated(uint128 head, Descriptor desc, uint256 arc);

    /**
     * @notice Emitted when multiple tails are unlinked from a head
     * @param head Encoded SID of the head object
     * @param desc Descriptor of the head after unlinking
     * @param arcs Array of encoded tails with relation and data
     */
    event Unrelated(uint128 head, Descriptor desc, uint256[] arcs);

    /**
     * @notice Links a tail object to a head object using a relation
     * @param tail Encoded SID of the tail (data, grant, set, id)
     * @param rel Relation ID
     * @param head Encoded SID of the head (data, grant, set, id)
     */
    function relate(uint256 tail, uint64 rel, uint256 head) external;

    // /**
    //  * @notice Links multiple tails to a head
    //  * @param tails Array of encoded SIDs of the tails (data, grant, set, id)
    //  * @param rel Relation ID
    //  * @param head Encoded SID of the head (data, grant, set, id)
    //  */
    // function relate(uint256[] memory tails, uint64 rel, uint256 head) external;

    /**
     * @notice Unlinks a tail object from a head object
     * @param tail Encoded SID of the tail (data, grant, set, id)
     * @param rel Relation ID
     * @param head Encoded SID of the head (data, grant, set, id)
     */
    function unrelate(uint256 tail, uint64 rel, uint256 head) external;

    // /**
    //  * @notice Unlinks multiple tails from a head
    //  * @param tails Array of encoded SIDs of the tails (data, grant, set, id)
    //  * @param rel Relation ID
    //  * @param head Encoded SID of the head (data, grant, set, id)
    //  */
    // function unrelate(uint256[] memory tails, uint64 rel, uint256 head) external;
}
