pragma solidity ^0.8.13;

import "./examples/MySetMinimal.sol";
import "forge-std/Test.sol";

contract Interoperable_Test is Test {
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
    }

    function test_Uri() public {
        string memory uri = set.uri();
        assertEq(uri, "http://image.local/mysetminimal/{id}/{rev}/meta", "URI should match");
    }
}
