pragma solidity ^0.8.13;

import "./examples/MySetMinimal.sol";

import {ISet} from "@periphery/interfaces/user/ISet.sol";
import "forge-std/Test.sol";

contract SetMinimalTest is Test {
    MySetMinimal set;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    bytes32[] elems = [bytes32("elem1"), bytes32("elem2")];

    function setUp() public {
        set = new MySetMinimal(17, 1, 18, 2);
    }

    function test_Mint() public {
        vm.prank(user);
        (uint64 id, Descriptor memory desc) = set.mint(user, elems);

        assertEq(id, 1, "First mint should have ID 1");
        assertEq(desc.kindId, set._kindId(), "Kind ID should match");
        assertEq(desc.kindRev, set._kindRev(), "Kind revision should match");
        assertEq(desc.setId, set._setId(), "Set ID should match");
        assertEq(desc.setRev, set._setRev(), "Set revision should match");

        // ai! check events
    }

    function test_Update() public {
        vm.prank(user);
        (uint64 id,) = set.mint(user, elems);

        bytes32[] memory newElems = new bytes32[](2);
        newElems[0] = bytes32("new1");
        newElems[1] = bytes32("new2");
        vm.expectEmit(true, true, true, true);
        emit ISet.Updated(id, Descriptor(0, 2, 1, 2, 17, 18), newElems);

        vm.prank(user);
        Descriptor memory desc = set.update(id, newElems);

        assertEq(desc.rev, 2, "Revision should increment");
        assertEq(desc.kindRev, 1, "Kind revision should stay same");
        assertEq(desc.setRev, 2, "Set revision should stay same");
    }

    function test_Upgrade() public {
        vm.prank(user);
        (uint64 id,) = set.mint(user, elems);

        // Upgrade to same revisions (no change)
        Descriptor memory expectedDesc = Descriptor(0, 2, 1, 2, 17, 18);
        vm.expectEmit(true, true, true, true);
        emit ISet.Upgraded(id, expectedDesc);

        vm.prank(user);
        Descriptor memory desc = set.upgrade(id, 1, 2);

        assertEq(desc.rev, 2, "Revision should increment");
        assertEq(desc.kindRev, 1, "Kind revision should stay same");
        assertEq(desc.setRev, 2, "Set revision should stay same");
    }

    function test_Transfer() public {
        vm.prank(user);
        (uint64 id,) = set.mint(user, elems);

        address newOwner = makeAddr("newOwner");
        vm.expectEmit(true, true, true, true);
        emit ISet.Transferred(id, user, newOwner);

        vm.prank(user);
        set.transfer(id, newOwner);

        assertEq(set.ownerOf(id), newOwner, "Ownership should transfer");
    }

    function test_Uri() public view {
        string memory uri = set.uri();
        assertEq(uri, "http://image.local/mysetminimal/{id}/{rev}/meta", "URI should match");
    }
}
