// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC7572} from "../interfaces/external/IERC7572.sol";
import {Descriptor, IERC165, ISet, SetBase} from "./SetBase.sol";
import {IERC1155, IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract SetERC1155Compat is SetBase, IERC1155, IERC1155MetadataURI, IERC7572 {
    error InvalidTransferAmount();
    error TransferFromIncorrectOwner();
    error LengthMismatch();
    error ZeroAddress();
    error SelfApproval();
    error NotOwnerNorApproved();

    mapping(address => mapping(address => bool)) private _approvals;

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
        return _uri(uint64(id), 0);
    }

    /// @inheritdoc IERC7572
    function contractURI() external view override returns (string memory) {
        return string.concat(_baseURI(), "meta");
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override(IERC165, SetBase) returns (bool) {
        return _supportsInterface(interfaceId);
    }

    function _supportsInterface(bytes4 interfaceId) internal pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId
            || interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC7572).interfaceId
            || interfaceId == type(ISet).interfaceId;
    }

    function _uri() internal view virtual override returns (string memory) {
        return string.concat(_baseURI(), "{id}/{rev}/meta");
    }

    function _uri(uint64 id, uint32 rev) internal view virtual returns (string memory) {
        return string.concat(_baseURI(), Strings.toString(id), "/", Strings.toString(rev), "/meta");
    }

    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
        if (to == address(0)) revert ZeroAddress();
        if (amount != 1) revert InvalidTransferAmount();
        if (_ownerOf(uint64(id)) != from) revert TransferFromIncorrectOwner();

        data; // silence warning
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

        data; // Silence unused variable warning
        address operator = msg.sender;
        for (uint256 i = 0; i < ids.length; ++i) {
            if (amounts[i] != 1) revert InvalidTransferAmount();
            uint64 id = uint64(ids[i]);
            if (_ownerOf(id) != from) revert TransferFromIncorrectOwner();
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
        return _ownerOf(uint64(id)) == account ? 1 : 0;
    }

    function _postCreate(uint64 id, Descriptor memory desc, bytes32[] memory elems, address owner)
        internal
        virtual
        override
    {
        emit Created(id, desc, elems, owner);
        emit TransferSingle(msg.sender, address(0), owner, id, 1);
        emit URI(_uri(id, desc.rev), id);
    }

    function _postUpgrade(uint64 id, Descriptor memory desc, uint32 kindRev, uint32 setRev) internal virtual override {
        kindRev; // slient warnings
        setRev; // slient warnings
        emit Upgraded(id, desc);
        emit URI(_uri(id, desc.rev), id);
    }

    function _postUpdate(uint64 id, Descriptor memory desc, bytes32[] memory elems) internal virtual override {
        emit Updated(id, desc, elems);
        emit URI(_uri(id, desc.rev), id);
    }

    function _postTouch(uint64 id, Descriptor memory desc) internal virtual override {
        emit Touched(id, desc);
        emit URI(_uri(id, desc.rev), id);
    }

    function _postTransfer(uint64 id, address from, address to) internal virtual override {
        emit Transferred(id, from, to);
        emit TransferSingle(msg.sender, from, to, id, 1);
    }

    function _baseURI() internal view virtual returns (string memory);
}
