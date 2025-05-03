// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../test/examples/MySet1155.sol";

contract Set1155Test is Test {
    // Protocol roles
    address protoAdmin = makeAddr("protoAdmin");
    address setOwner = makeAddr("setOwner");
    address caller = makeAddr("caller");
    address holder = makeAddr("holder");

    MySet1155 set;

    function setUp() public {
        set = new MySet1155();
    }

    function test_MintAndTransfer() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        // Mint to holder
        vm.prank(setOwner);
        (uint64 id, ) = set.mint(holder, elems);

        // Verify ownership
        assertEq(set.ownerOf(id), holder);
        assertEq(set.balanceOf(holder, id), 1);

        // Transfer to caller
        vm.prank(holder);
        set.safeTransferFrom(holder, caller, id, 1, "");

        // Verify new owner
        assertEq(set.ownerOf(id), caller);
        assertEq(set.balanceOf(holder, id), 0);
        assertEq(set.balanceOf(caller, id), 1);
    }

    function test_URI() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        vm.prank(setOwner);
        (uint64 id, ) = set.mint(holder, elems);

        // Check token URI
        string memory uri = set.uri(id);
        assertTrue(bytes(uri).length > 0);

        // Check contract URI
        string memory contractURI = set.contractURI();
        assertTrue(bytes(contractURI).length > 0);
    }

    function test_Upgrade() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        vm.prank(setOwner);
        (uint64 id, Descriptor memory desc) = set.mint(holder, elems);
        uint32 initialRev = desc.rev;

        // Upgrade kind revision
        vm.prank(holder);
        desc = set.upgrade(id, 1, 0);
        assertEq(desc.rev, initialRev + 1);
        assertEq(desc.kindRev, 1);

        // Upgrade set revision
        vm.prank(holder);
        desc = set.upgrade(id, 0, 1);
        assertEq(desc.rev, initialRev + 2);
        assertEq(desc.setRev, 1);
    }

    function test_Update() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        vm.prank(setOwner);
        (uint64 id, Descriptor memory desc) = set.mint(holder, elems);
        uint32 initialRev = desc.rev;

        // Update elements
        bytes32[] memory newElems = new bytes32[](2);
        newElems[0] = keccak256("new element 1");
        newElems[1] = keccak256("new element 2");

        vm.prank(holder);
        desc = set.update(id, newElems); // This should now work with the added update function
        assertEq(desc.rev, initialRev + 1);

        // Verify elements updated
        bytes32[] memory storedElems = set.elementsAt(id, 0);
        assertEq(storedElems.length, 2);
        assertEq(storedElems[0], newElems[0]);
        assertEq(storedElems[1], newElems[1]);
    }
}
