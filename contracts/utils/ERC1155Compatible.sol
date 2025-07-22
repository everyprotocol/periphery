// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC1155, IERC1155MetadataURI} from "../interfaces/external/IERC1155MetadataURI.sol";
import {IERC7572} from "../interfaces/external/IERC7572.sol";
import {Descriptor, IERC165, ISet, SetSolo} from "./SetSolo.sol";

/// @title ERC1155Compatible
/// @notice A minimal ERC-1155 wrapper for object tokens in a Set, where each object has a quantity of exactly 1.
/// @dev Extends SetSolo and conforms to IERC1155, IERC1155MetadataURI, and IERC7572.
abstract contract ERC1155Compatible is SetSolo, IERC1155, IERC1155MetadataURI, IERC7572 {
    error InvalidTransferAmount();
    error TransferFromIncorrectOwner();
    error LengthMismatch();
    error ZeroAddress();
    error SelfApproval();
    error NotOwnerNorApproved();

    mapping(address => mapping(address => bool)) internal _approvals;

    /// @inheritdoc IERC1155
    function balanceOf(address account, uint256 id) external view override returns (uint256) {
        return _balanceOf(account, id);
    }

    /// @inheritdoc IERC1155
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        if (accounts.length != ids.length) revert LengthMismatch();

        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = _balanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    }

    /// @inheritdoc IERC1155
    function setApprovalForAll(address operator, bool approved) public {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    /// @inheritdoc IERC1155
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _approvals[account][operator];
    }

    /// @inheritdoc IERC1155
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public {
        if (from != msg.sender && !isApprovedForAll(from, msg.sender)) revert NotOwnerNorApproved();

        _safeTransferFrom(from, to, id, amount, data);
    }

    /// @inheritdoc IERC1155
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        if (from != msg.sender && !isApprovedForAll(from, msg.sender)) revert NotOwnerNorApproved();
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /// @inheritdoc IERC1155MetadataURI
    function uri(uint256 id) public view override returns (string memory) {
        uint64 id64 = uint64(id);
        Descriptor memory od = _decriptor(id64, 0);
        return _tokenURI(id64, od.rev);
    }

    /// @inheritdoc IERC7572
    function contractURI() external view override returns (string memory) {
        return _contractURI();
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override(IERC165, SetSolo) returns (bool) {
        return _supportsInterface(interfaceId);
    }

    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
        if (to == address(0)) revert ZeroAddress();
        if (amount != 1) revert InvalidTransferAmount();
        if (_owner(uint64(id)) != from) revert TransferFromIncorrectOwner();

        data; // Unused
        _transfer(uint64(id), to);
        _postTransfer(uint64(id), from, to);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        if (to == address(0)) revert ZeroAddress();
        if (amounts.length != ids.length) revert LengthMismatch();

        data; // Unused
        address operator = msg.sender;
        for (uint256 i = 0; i < ids.length; ++i) {
            if (amounts[i] != 1) revert InvalidTransferAmount();
            uint64 id = uint64(ids[i]);
            if (_owner(id) != from) revert TransferFromIncorrectOwner();
            _transfer(id, to);
            emit Transferred(id, from, to);
        }
        emit TransferBatch(operator, from, to, ids, amounts);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal {
        if (owner == operator) revert SelfApproval();

        _approvals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _balanceOf(address account, uint256 id) internal view returns (uint256) {
        return _owner(uint64(id)) == account ? 1 : 0;
    }

    function _postCreate(address owner, uint64 id, Descriptor memory od, bytes32[] memory elems)
        internal
        virtual
        override
    {
        // Set events
        emit Created(id, od, elems, owner);
        // ERC1155 events
        emit TransferSingle(msg.sender, address(0), owner, id, 1);
        emit URI(_tokenURI(id, od.rev), id);
    }

    function _postUpgrade(uint64 id, Descriptor memory od, uint32 kindRev, uint32 setRev) internal virtual override {
        (kindRev, setRev); // Unused
        // Set events
        emit Upgraded(id, od);
        // ERC1155 events
        emit URI(_tokenURI(id, od.rev), id);
    }

    function _postUpdate(uint64 id, Descriptor memory od, bytes32[] memory elems) internal virtual override {
        // Set events
        emit Updated(id, od, elems);
        // ERC1155 events
        emit URI(_tokenURI(id, od.rev), id);
    }

    function _postTouch(uint64 id, Descriptor memory od) internal virtual override {
        // Set events
        emit Touched(id, od);
        // ERC1155 events
        emit URI(_tokenURI(id, od.rev), id);
    }

    function _postTransfer(uint64 id, address from, address to) internal virtual override {
        // Set events
        emit Transferred(id, from, to);
        // ERC1155 events
        emit TransferSingle(msg.sender, from, to, id, 1);
    }

    function _supportsInterface(bytes4 interfaceId) internal pure virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(ISet).interfaceId
            || interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId
            || interfaceId == type(IERC7572).interfaceId;
    }

    function _tokenURI(uint64 id, uint32 rev) internal view virtual returns (string memory);

    function _contractURI() internal view virtual returns (string memory);
}
