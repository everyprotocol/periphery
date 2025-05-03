// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title ISet
 * @notice Interface for set contracts
 */
interface ISet is IERC165 {
    // --- Events ---

    /**
     * @notice Emitted when a new object is created
     * @param id ID of the object
     * @param desc Descriptor of the object
     * @param elems Elements of the object
     * @param owner Initial owner of the object
     */
    event Created(uint64 id, Descriptor desc, bytes32[] elems, address owner);

    /**
     * @notice Emitted when an object is updated
     * @param id ID of the object
     * @param desc Updated descriptor
     * @param elems Updated elements
     */
    event Updated(uint64 id, Descriptor desc, bytes32[] elems);

    /**
     * @notice Emitted when an object is upgraded
     * @param id ID of the object
     * @param desc Descriptor after upgrade
     */
    event Upgraded(uint64 id, Descriptor desc);

    /**
     * @notice Emitted when an object is touched
     * @param id ID of the object
     * @param desc Latest descriptor
     */
    event Touched(uint64 id, Descriptor desc);

    /**
     * @notice Emitted when an object is destroyed
     * @param id ID of the object
     * @param desc Descriptor before destruction
     */
    event Destroyed(uint64 id, Descriptor desc);

    /**
     * @notice Emitted when ownership is transferred
     * @param id ID of the object
     * @param from Previous owner
     * @param to New owner
     */
    event Transferred(uint64 id, address from, address to);

    // --- External Methods ---

    /**
     * @notice Upgrade an object to a new kind or set revision
     * @param id ID of the object
     * @param kindRev New kind revision (0 = no change)
     * @param setRev New set revision (0 = no change)
     * @return desc Descriptor after upgrade
     */
    function upgrade(uint64 id, uint32 kindRev, uint32 setRev) external returns (Descriptor memory desc);

    /**
     * @notice Bump an object's revision (e.g. for timestamp update)
     * @param id ID of the object
     * @return desc Descriptor after touch
     */
    function touch(uint64 id) external returns (Descriptor memory desc);

    /**
     * @notice Transfer ownership of an object
     * @param id ID of the object
     * @param to Address of the new owner
     */
    function transfer(uint64 id, address to) external;

    /**
     * @notice Resolve a valid revision number
     * @param id ID of the object
     * @param rev0 Revision to check (0 = latest)
     * @return rev Valid revision (0 if invalid)
     */
    function revision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /**
     * @notice Get base URI template for object metadata
     * @dev Placeholders {id} and {rev} must be replaced by client
     * @return _uri URI template string
     */
    function uri() external view returns (string memory _uri);

    /**
     * @notice Get the descriptor and owner
     * @param id ID of the object
     * @return desc Latest descriptor
     * @return owner Current owner address
     */
    function sotaOf(uint64 id) external view returns (Descriptor memory desc, address owner);

    /**
     * @notice Get current owner of an object
     * @param id ID of the object
     * @return owner Address of the owner
     */
    function ownerOf(uint64 id) external view returns (address owner);

    /**
     * @notice Get descriptor at a specific revision
     * @param id ID of the object
     * @param rev Revision number (0 = latest)
     * @return desc Descriptor at the specified revision
     */
    function descriptorAt(uint64 id, uint32 rev) external view returns (Descriptor memory desc);

    /**
     * @notice Get elements at a specific revision
     * @param id ID of the object
     * @param rev Revision number (0 = latest)
     * @return elements Array of elements at the revision
     */
    function elementsAt(uint64 id, uint32 rev) external view returns (bytes32[] memory elements);
}
