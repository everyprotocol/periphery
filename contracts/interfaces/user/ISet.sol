// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Descriptor} from "../../types/Descriptor.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title ISet
/// @notice Core interface for set contracts
interface ISet is IERC165 {
    // --- Events ---

    /// @notice Emitted when a new object is created
    /// @param id Object ID
    /// @param od Object descriptor
    /// @param elems Elements of the object
    /// @param owner Initial owner
    event Created(uint64 id, Descriptor od, bytes32[] elems, address owner);

    /// @notice Emitted when an object is updated
    /// @param id Object ID
    /// @param od Updated descriptor
    /// @param elems Updated elements
    event Updated(uint64 id, Descriptor od, bytes32[] elems);

    /// @notice Emitted when an object is upgraded
    /// @param id Object ID
    /// @param od Descriptor after upgrade
    event Upgraded(uint64 id, Descriptor od);

    /// @notice Emitted when an object is touched (bumped without content change)
    /// @param id Object ID
    /// @param od Latest descriptor
    event Touched(uint64 id, Descriptor od);

    /// @notice Emitted when an object is destroyed
    /// @param id Object ID
    /// @param od Descriptor before destruction
    event Destroyed(uint64 id, Descriptor od);

    /// @notice Emitted when ownership is transferred
    /// @param id Object ID
    /// @param from Previous owner
    /// @param to New owner
    event Transferred(uint64 id, address from, address to);

    // --- Write Methods ---

    /// @notice Create (mint) a new object
    /// @param to Initial owner of the object
    /// @param id0 Requested object ID (0 = auto-assign)
    /// @param data Encoded creation parameters
    /// @return id Final resolved object ID
    /// @return od Descriptor of the newly created object
    function create(address to, uint64 id0, bytes calldata data) external returns (uint64 id, Descriptor memory od);

    /// @notice Update an existing object
    /// @param id Object ID to update
    /// @param data Encoded update parameters
    /// @return od Descriptor after the update
    function update(uint64 id, bytes calldata data) external returns (Descriptor memory od);

    /// @notice Upgrade an object to a new kind or set revision
    /// @param id Object ID
    /// @param kindRev0 New kind revision (0 = no change)
    /// @param setRev0 New set revision (0 = no change)
    /// @return od Descriptor after upgrade
    function upgrade(uint64 id, uint32 kindRev0, uint32 setRev0) external returns (Descriptor memory od);

    /// @notice Touch an object to increment revision without content change
    /// @param id Object ID
    /// @return od Descriptor after touch
    function touch(uint64 id) external returns (Descriptor memory od);

    /// @notice Transfer ownership of an object
    /// @param id Object ID
    /// @param to Address of the new owner
    function transfer(uint64 id, address to) external;

    // --- Read Methods ---

    /// @notice Get current owner of an object
    /// @param id Object ID
    /// @return owner_ Current owner address
    function owner(uint64 id) external view returns (address owner_);

    /// @notice Get descriptor at a specific revision
    /// @param id Object ID
    /// @param rev0 Revision number (0 = latest)
    /// @return od Descriptor at that revision
    function descriptor(uint64 id, uint32 rev0) external view returns (Descriptor memory od);

    /// @notice Get descriptor and elements at a specific revision
    /// @param id Object ID
    /// @param rev0 Revision number to query (0 = latest)
    /// @return od Descriptor at the specified revision
    /// @return elems Elements at the specified revision
    function snapshot(uint64 id, uint32 rev0) external view returns (Descriptor memory od, bytes32[] memory elems);

    /// @notice Get URI template for metadata
    /// @dev Client should replace `{id}` and `{rev}` placeholders
    /// @return uri_ URI template string
    function uri() external view returns (string memory uri_);
}
