// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, SetERC1155} from "@everyprotocol/periphery/SetERC1155.sol";
import {ISet} from "@everyprotocol/periphery/interfaces/user/ISet.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "forge-std/Test.sol";

contract MySetERC1155 is SetERC1155 {
    constructor(uint64 kindId, uint32 kindRev, uint64 setId, uint32 setRev)
        SetERC1155(kindId, kindRev, setId, setRev)
    {}

    function upgradeObjectKind(uint32 kindRev) external {
        _initialDesc.kindRev = kindRev;
    }

    function upgradeObjectSet(uint32 setRev) external {
        _initialDesc.setRev = setRev;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://example.com/myset1155/";
    }
}

contract SetERC1155_Test is Test {
    // Protocol roles
    address protoAdmin = makeAddr("protoAdmin");
    address setOwner = makeAddr("setOwner");
    address caller = makeAddr("caller");
    address holder = makeAddr("holder");

    MySetERC1155 set;

    function setUp() public {
        set = new MySetERC1155(17, 1, 18, 2);
    }

    function test_MintAndTransfer() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        // Mint to holder
        vm.prank(setOwner);
        vm.expectEmit(true, true, true, true);
        emit ISet.Created(1, Descriptor(0, 1, 1, 2, 17, 18), elems, holder);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(setOwner, address(0), holder, 1, 1);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.URI("https://example.com/myset1155/1/1/meta", 1);
        (uint64 id,) = set.mint(holder, elems);

        // Verify ownership
        assertEq(set.owner(id), holder);
        assertEq(set.balanceOf(holder, id), 1);

        // Transfer to caller
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit ISet.Transferred(id, holder, caller);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(holder, holder, caller, id, 1);
        set.safeTransferFrom(holder, caller, id, 1, "");

        // Verify new owner
        assertEq(set.owner(id), caller);
        assertEq(set.balanceOf(holder, id), 0);
        assertEq(set.balanceOf(caller, id), 1);
    }

    function test_URI() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        vm.prank(setOwner);
        vm.expectEmit(true, true, true, true);
        emit ISet.Created(1, Descriptor(0, 1, 1, 2, 17, 18), elems, holder);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(setOwner, address(0), holder, 1, 1);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.URI("https://example.com/myset1155/1/1/meta", 1);
        (uint64 id,) = set.mint(holder, elems);

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
        set.upgradeObjectKind(6);
        set.upgradeObjectSet(7);

        // Upgrade kind revision
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit ISet.Upgraded(id, Descriptor(0, initialRev + 1, 4, 2, 17, 18));
        vm.expectEmit(true, true, true, true);
        emit IERC1155.URI("https://example.com/myset1155/1/2/meta", 1);
        desc = set.upgrade(id, 4, 0);
        assertEq(desc.rev, initialRev + 1);
        assertEq(desc.kindRev, 4);

        // Upgrade set revision
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit ISet.Upgraded(id, Descriptor(0, initialRev + 2, 4, 3, 17, 18));
        vm.expectEmit(true, true, true, true);
        emit IERC1155.URI("https://example.com/myset1155/1/3/meta", 1);
        desc = set.upgrade(id, 0, 3);
        assertEq(desc.rev, initialRev + 2);
        assertEq(desc.setRev, 3);
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
        vm.expectEmit(true, true, true, true);
        emit ISet.Updated(id, Descriptor(0, initialRev + 1, 1, 2, 17, 18), newElems);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.URI("https://example.com/myset1155/1/2/meta", 1);
        desc = set.update(id, newElems);
        assertEq(desc.rev, initialRev + 1);

        // Verify elements updated
        bytes32[] memory storedElems = set.elements(id, 0);
        assertEq(storedElems.length, 2);
        assertEq(storedElems[0], newElems[0]);
        assertEq(storedElems[1], newElems[1]);
    }

    function test_ERC1155_BatchTransfer() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        // Mint two tokens to holder
        vm.prank(setOwner);
        (uint64 id1,) = set.mint(holder, elems);
        vm.prank(setOwner);
        (uint64 id2,) = set.mint(holder, elems);

        // Prepare batch transfer
        uint256[] memory ids = new uint256[](2);
        ids[0] = id1;
        ids[1] = id2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;

        // Transfer batch
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit ISet.Transferred(id1, holder, caller);
        vm.expectEmit(true, true, true, true);
        emit ISet.Transferred(id2, holder, caller);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferBatch(holder, holder, caller, ids, amounts);
        set.safeBatchTransferFrom(holder, caller, ids, amounts, "");

        // Verify new owners
        assertEq(set.owner(id1), caller);
        assertEq(set.owner(id2), caller);
    }

    function test_ERC1155_Approval() public {
        // Check initial approval state
        assertFalse(set.isApprovedForAll(holder, caller));

        // Set approval
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit IERC1155.ApprovalForAll(holder, caller, true);
        set.setApprovalForAll(caller, true);

        // Verify approval
        assertTrue(set.isApprovedForAll(holder, caller));
    }

    function test_ERC1155_BalanceOfBatch() public {
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");

        // Mint tokens to different accounts
        vm.prank(setOwner);
        (uint64 id1,) = set.mint(holder, elems);
        vm.prank(setOwner);
        (uint64 id2,) = set.mint(caller, elems);

        // Prepare batch query
        address[] memory accounts = new address[](2);
        accounts[0] = holder;
        accounts[1] = caller;
        uint256[] memory ids = new uint256[](2);
        ids[0] = id1;
        ids[1] = id2;

        // Check balances
        uint256[] memory balances = set.balanceOfBatch(accounts, ids);
        assertEq(balances[0], 1);
        assertEq(balances[1], 1);
    }
}
