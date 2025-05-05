// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./examples/MySetFull.sol";
import {ISet} from "@everyprotocol/periphery/interfaces/user/ISet.sol";
import {IRemoteMintable} from "@everyprotocol/periphery/interfaces/user/IRemoteMintable.sol";
import {IInteroperable} from "@everyprotocol/periphery/interfaces/user/IInteroperable.sol";
import {IObjectMinter} from "@everyprotocol/periphery/interfaces/core/IObjectMinter.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "forge-std/Test.sol";

contract SetFull_Test is Test {
    // Protocol roles
    address protoAdmin = makeAddr("protoAdmin");
    address setOwner = makeAddr("setOwner");
    address caller = makeAddr("caller");
    address holder = makeAddr("holder");
    address minter = makeAddr("minter");
    address setRegistry = makeAddr("setRegistry");

    MySetFull set;
    uint64 constant KIND_ID = 17;
    uint32 constant KIND_REV = 1;
    uint64 constant SET_ID = 18;
    uint32 constant SET_REV = 2;

    function setUp() public {
        vm.mockCall(
            setRegistry,
            abi.encodeWithSignature("omniRegistry()"),
            abi.encode(makeAddr("omniRegistry"))
        );
        vm.mockCall(
            setRegistry,
            abi.encodeWithSignature("kindRegistry()"),
            abi.encode(makeAddr("kindRegistry"))
        );
        vm.mockCall(
            setRegistry,
            abi.encodeWithSignature("elementRegistry()"),
            abi.encode(makeAddr("elementRegistry"))
        );

        set = new MySetFull(setOwner, minter, setRegistry, KIND_ID, KIND_REV);
    }

    function test_Initialization() public {
        assertEq(set.owner(), setOwner, "Owner should be set correctly");
        assertEq(set.objectMinter(), minter, "Minter should be set correctly");
        assertEq(set._kindId(), KIND_ID, "Kind ID should be set correctly");
    }

    function test_RemoteMint() public {
        // Prepare mint data
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");
        bytes memory data = abi.encode(elems);
        
        // Context value (packed as per IRemoteMintable.Context)
        uint256 context = uint256(uint32(1)) | // tag
                          (uint256(uint32(0)) << 32) | // policy
                          (uint256(uint64(1)) << 64) | // rangeStart
                          (uint256(uint64(100)) << 128); // rangeEnd
        
        // Mock minter call
        vm.prank(minter);
        (bytes4 selector, uint64 id) = set.onObjectMint(caller, holder, 42, context, data);
        
        // Verify results
        assertEq(selector, IRemoteMintable.onObjectMint.selector, "Should return correct selector");
        assertEq(id, 42, "Should return the requested ID");
        assertEq(set.ownerOf(id), holder, "Holder should own the minted object");
    }

    function test_RemoteMintRevertOnZeroId() public {
        bytes memory data = abi.encode(new bytes32[](1));
        uint256 context = 0;
        
        vm.prank(minter);
        vm.expectRevert(MySetFull.ObjectIdUnspecified.selector);
        set.onObjectMint(caller, holder, 0, context, data);
    }

    function test_ERC1155Compatibility() public {
        // Mint a token
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");
        bytes memory data = abi.encode(elems);
        
        vm.prank(minter);
        (bytes4 selector, uint64 id) = set.onObjectMint(caller, holder, 42, 0, data);
        assertEq(selector, IRemoteMintable.onObjectMint.selector);
        
        // Check ERC1155 balance
        assertEq(set.balanceOf(holder, id), 1, "Balance should be 1");
        
        // Test approval
        vm.prank(holder);
        set.setApprovalForAll(caller, true);
        assertTrue(set.isApprovedForAll(holder, caller), "Approval should be set");
        
        // Test transfer
        vm.prank(caller);
        set.safeTransferFrom(holder, caller, id, 1, "");
        assertEq(set.ownerOf(id), caller, "Ownership should be transferred");
        assertEq(set.balanceOf(holder, id), 0, "Previous owner should have 0 balance");
        assertEq(set.balanceOf(caller, id), 1, "New owner should have balance of 1");
    }

    function test_InteroperableCallbacks() public {
        // Test onSetRegister callback
        Descriptor memory desc = Descriptor(0, 1, KIND_REV, SET_REV, KIND_ID, SET_ID);
        
        vm.prank(setRegistry);
        bytes4 selector = set.onSetRegister(SET_ID, desc);
        assertEq(selector, IInteroperable.onSetRegister.selector, "Should return correct selector");
        
        // Test onSetUpdate callback
        desc.rev = 2;
        vm.prank(setRegistry);
        selector = set.onSetUpdate(SET_ID, desc);
        assertEq(selector, IInteroperable.onSetUpdate.selector, "Should return correct selector");
        
        // Test onSetUpgrade callback
        desc.rev = 3;
        vm.prank(setRegistry);
        selector = set.onSetUpgrade(SET_ID, desc);
        assertEq(selector, IInteroperable.onSetUpgrade.selector, "Should return correct selector");
        
        // Test onSetTouch callback
        desc.rev = 4;
        vm.prank(setRegistry);
        selector = set.onSetTouch(SET_ID, desc);
        assertEq(selector, IInteroperable.onSetTouch.selector, "Should return correct selector");
    }

    function test_ObjectRelationCallbacks() public {
        // Mint an object first
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");
        bytes memory data = abi.encode(elems);
        
        vm.prank(minter);
        (bytes4 selector, uint64 id) = set.onObjectMint(caller, holder, 42, 0, data);
        
        // Mock omniRegistry address for relation callbacks
        address omniRegistry = makeAddr("omniRegistry");
        vm.mockCall(
            setRegistry,
            abi.encodeWithSignature("omniRegistry()"),
            abi.encode(omniRegistry)
        );
        
        // Test onObjectRelate callback
        vm.prank(omniRegistry);
        Descriptor memory desc = set.onObjectRelate(id, 1, 0, 0, 0, 0);
        assertEq(desc.rev, 2, "Revision should be incremented");
        
        // Test onObjectUnrelate callback
        vm.prank(omniRegistry);
        desc = set.onObjectUnrelate(id, 1, 0, 0, 0, 0);
        assertEq(desc.rev, 3, "Revision should be incremented again");
    }

    function test_ObjectTransferCallback() public {
        // Mint an object first
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");
        bytes memory data = abi.encode(elems);
        
        vm.prank(minter);
        (bytes4 selector, uint64 id) = set.onObjectMint(caller, holder, 42, 0, data);
        
        // Mock omniRegistry address for transfer callback
        address omniRegistry = makeAddr("omniRegistry");
        vm.mockCall(
            setRegistry,
            abi.encodeWithSignature("omniRegistry()"),
            abi.encode(omniRegistry)
        );
        
        // Test onObjectTransfer callback
        vm.prank(omniRegistry);
        selector = set.onObjectTransfer(id, holder, caller);
        assertEq(selector, IInteroperable.onObjectTransfer.selector, "Should return correct selector");
        assertEq(set.ownerOf(id), caller, "Ownership should be transferred");
    }

    function test_MintPolicyManagement() public {
        // Create a mock ObjectMinter that will record calls
        MockObjectMinter mockMinter = new MockObjectMinter();
        MySetFull testSet = new MySetFull(setOwner, address(mockMinter), setRegistry, KIND_ID, KIND_REV);
        
        // Create a mint policy
        IObjectMinter.MintPolicy memory policy = IObjectMinter.MintPolicy({
            index: 0,
            status: IObjectMinter.MintPolicyStatus.Enabled,
            permType: IObjectMinter.MintPermissionType.Public,
            tag: 1,
            mintLimit: 10,
            fundsRecipient: setOwner,
            currency: address(0),
            mintPrice: 0.1 ether,
            rangeStart: 1,
            rangeEnd: 100,
            saleStart: uint64(block.timestamp),
            saleEnd: uint64(block.timestamp + 1 days),
            permData: bytes32(0)
        });
        
        // Test adding a mint policy
        vm.prank(setOwner);
        testSet.addMintPolicy(policy);
        assertTrue(mockMinter.addPolicyCalled(), "addMintPolicy should be called");
        
        // Test disabling a mint policy
        vm.prank(setOwner);
        testSet.disableMintPolicy(1);
        assertTrue(mockMinter.disablePolicyCalled(), "disableMintPolicy should be called");
        
        // Test enabling a mint policy
        vm.prank(setOwner);
        testSet.enableMintPolicy(1);
        assertTrue(mockMinter.enablePolicyCalled(), "enableMintPolicy should be called");
    }

    function test_OwnerOnlyFunctions() public {
        IObjectMinter.MintPolicy memory policy = IObjectMinter.MintPolicy({
            index: 0,
            status: IObjectMinter.MintPolicyStatus.Enabled,
            permType: IObjectMinter.MintPermissionType.Public,
            tag: 1,
            mintLimit: 10,
            fundsRecipient: setOwner,
            currency: address(0),
            mintPrice: 0.1 ether,
            rangeStart: 1,
            rangeEnd: 100,
            saleStart: uint64(block.timestamp),
            saleEnd: uint64(block.timestamp + 1 days),
            permData: bytes32(0)
        });
        
        // Test that non-owner cannot add mint policy
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        set.addMintPolicy(policy);
        
        // Test that non-owner cannot disable mint policy
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        set.disableMintPolicy(1);
        
        // Test that non-owner cannot enable mint policy
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        set.enableMintPolicy(1);
    }

    function test_SupportsInterface() public {
        // Test support for ISet interface
        assertTrue(set.supportsInterface(type(ISet).interfaceId), "Should support ISet interface");
        
        // Test support for IRemoteMintable interface
        assertTrue(set.supportsInterface(type(IRemoteMintable).interfaceId), "Should support IRemoteMintable interface");
        
        // Test support for IInteroperable interface
        assertTrue(set.supportsInterface(type(IInteroperable).interfaceId), "Should support IInteroperable interface");
        
        // Test support for IERC1155 interface
        assertTrue(set.supportsInterface(type(IERC1155).interfaceId), "Should support IERC1155 interface");
        
        // Test support for IERC165 interface
        assertTrue(set.supportsInterface(type(IERC165).interfaceId), "Should support IERC165 interface");
    }

    function test_URI() public {
        // Test the URI functions
        string memory baseUri = set.uri();
        assertEq(baseUri, "https://example.com/mysetfull/{id}/{rev}/meta", "Base URI should match");
        
        // Mint a token to test token-specific URI
        bytes32[] memory elems = new bytes32[](1);
        elems[0] = keccak256("test element");
        bytes memory data = abi.encode(elems);
        
        vm.prank(minter);
        (bytes4 selector, uint64 id) = set.onObjectMint(caller, holder, 42, 0, data);
        
        string memory tokenUri = set.uri(id);
        assertEq(tokenUri, "https://example.com/mysetfull/42/1/meta", "Token URI should match");
        
        // Test contract URI
        string memory contractUri = set.contractURI();
        assertEq(contractUri, "https://example.com/mysetfull/meta", "Contract URI should match");
    }
}

// Mock ObjectMinter for testing mint policy management
contract MockObjectMinter {
    bool private _addPolicyCalled;
    bool private _disablePolicyCalled;
    bool private _enablePolicyCalled;
    
    function mintPolicyAdd(IObjectMinter.MintPolicy memory) external returns (uint32) {
        _addPolicyCalled = true;
        return 1;
    }
    
    function mintPolicyDisable(uint32) external {
        _disablePolicyCalled = true;
    }
    
    function mintPolicyEnable(uint32) external {
        _enablePolicyCalled = true;
    }
    
    function addPolicyCalled() external view returns (bool) {
        return _addPolicyCalled;
    }
    
    function disablePolicyCalled() external view returns (bool) {
        return _disablePolicyCalled;
    }
    
    function enablePolicyCalled() external view returns (bool) {
        return _enablePolicyCalled;
    }
}
