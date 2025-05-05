// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title ISet
 * @notice Minimal interface for set contracts
 */
interface ISet is IERC165 {
    // --- Events ---

    /**
     * @notice Emitted when a new object is created
     * @param id Object ID
     * @param od Object descriptor
     * @param elems Elements of the object
     * @param owner Initial owner
     */
    event Created(uint64 id, Descriptor od, bytes32[] elems, address owner);

    /**
     * @notice Emitted when an object is updated
     * @param id Object ID
     * @param od Updated descriptor
     * @param elems Updated elements
     */
    event Updated(uint64 id, Descriptor od, bytes32[] elems);

    /**
     * @notice Emitted when an object is upgraded
     * @param id Object ID
     * @param od Descriptor after upgrade
     */
    event Upgraded(uint64 id, Descriptor od);

    /**
     * @notice Emitted when an object is touched (bumped without content change)
     * @param id Object ID
     * @param od Latest descriptor
     */
    event Touched(uint64 id, Descriptor od);

    /**
     * @notice Emitted when an object is destroyed
     * @param id Object ID
     * @param od Descriptor before destruction
     */
    event Destroyed(uint64 id, Descriptor od);

    /**
     * @notice Emitted when ownership is transferred
     * @param id Object ID
     * @param from Previous owner
     * @param to New owner
     */
    event Transferred(uint64 id, address from, address to);

    // --- External Methods ---

    /**
     * @notice Upgrade an object to a new kind or set revision
     * @param id Object ID
     * @param kindRev0 New kind revision (0 = no change)
     * @param setRev0 New set revision (0 = no change)
     * @return od Descriptor after upgrade
     */
    function upgrade(uint64 id, uint32 kindRev0, uint32 setRev0) external returns (Descriptor memory od);

    /**
     * @notice Touch an object to increment revision without content change
     * @param id Object ID
     * @return od Descriptor after touch
     */
    function touch(uint64 id) external returns (Descriptor memory od);

    /**
     * @notice Transfer ownership of an object
     * @param id Object ID
     * @param to Address of the new owner
     */
    function transfer(uint64 id, address to) external;

    /**
     * @notice Get URI template for metadata
     * @dev Client should replace `{id}` and `{rev}` placeholders
     * @return uri_ URI template string
     */
    function uri() external view returns (string memory uri_);

    /**
     * @notice Get current owner of an object
     * @param id Object ID
     * @return owner_ Current owner address
     */
    function owner(uint64 id) external view returns (address owner_);

    /**
     * @notice Resolve and validate a revision number
     * @param id Object ID
     * @param rev0 Revision to check (0 = latest)
     * @return rev Valid revision (0 if invalid)
     */
    function revision(uint64 id, uint32 rev0) external view returns (uint32 rev);

    /**
     * @notice Get descriptor at a specific revision
     * @param id Object ID
     * @param rev0 Revision number (0 = latest)
     * @return od Descriptor at that revision
     */
    function descriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory od);

    /**
     * @notice Get elements at a specific revision
     * @param id Object ID
     * @param rev0 Revision number (0 = latest)
     * @return elems Elements array at that revision
     */
    function elements(uint64 id, uint32 rev0) external view returns (bytes32[] memory elems);

    /**
     * @notice Get the latest descriptor and current owner
     * @param id Object ID
     * @return od Descriptor at the specified revision
     * @return owner_ Current owner (not historical)
     */
    function sota(uint64 id) external view returns (Descriptor memory od, address owner_);

    /**
     * @notice Get descriptor and elements at a specific revision
     * @param id Object ID
     * @param rev0 Revision number to query (0 = latest)
     * @return od Descriptor at the specified revision
     * @return elems Elements at the specified revision
     */
    function snapshot(uint64 id, uint32 rev0) external view returns (Descriptor memory od, bytes32[] memory elems);
}
