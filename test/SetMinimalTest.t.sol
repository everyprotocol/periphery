pragma solidity ^0.8.13;

import "./examples/MySetMinimal.sol";
import "forge-std/Test.sol";

contract SetMinimalTest is Test {
    MySetMinimal set;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    bytes32[] testElements = [bytes32("elem1"), bytes32("elem2")];

    function setUp() public {
        set = new MySetMinimal();
    }

    function test_Mint() public {
        vm.prank(user);
        (uint64 id, MySetMinimal.Descriptor memory desc) = set.mint(user, testElements);

        assertEq(id, 1, "First mint should have ID 1");
        assertEq(desc.kindId, set._kindId(), "Kind ID should match");
        assertEq(desc.kindRev, set._kindRev(), "Kind revision should match");
        assertEq(desc.setId, set._setId(), "Set ID should match");
        assertEq(desc.setRev, set._setRev(), "Set revision should match");
    }

    function test_UnsupportedKindId() public {
        vm.expectRevert(abi.encodeWithSelector(MySetMinimal.UnsupportedKindId.selector));
        set._kindRevision(999, 0);
    }

    function test_UnsupportedKindRevision() public {
        vm.expectRevert(abi.encodeWithSelector(MySetMinimal.UnsupportedKindRevision.selector));
        set._kindRevision(set._kindId(), set._kindRev() + 1);
    }

    function test_UnsupportedSetId() public {
        vm.expectRevert(abi.encodeWithSelector(MySetMinimal.UnsupportedSetId.selector));
        set._setRevision(999, 0);
    }

    function test_UnsupportedSetRevision() public {
        vm.expectRevert(abi.encodeWithSelector(MySetMinimal.UnsupportedSetRevision.selector));
        set._setRevision(set._setId(), set._setRev() + 1);
    }

    function test_Uri() public {
        string memory uri = set._uri();
        assertEq(uri, "http://image.local/mysetminimal/{id}/{rev}/meta", "URI should match");
    }
}
