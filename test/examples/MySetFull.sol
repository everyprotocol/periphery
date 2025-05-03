// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, SetERC1155Compat} from "@everyprotocol/periphery/sets/SetERC1155Compat.sol";
import {IInteroperable, SetInteroperable} from "@everyprotocol/periphery/sets/SetInteroperable.sol";
import {IRemoteMintable, SetRemoteMintable} from "@everyprotocol/periphery/sets/SetRemoteMintable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MySetFull is SetERC1155Compat, SetInteroperable, SetRemoteMintable, Ownable {
    modifier onlySetOwner() override(SetInteroperable, SetRemoteMintable) {
        _checkOwner();
        _;
    }

    constructor(address owner, address minter, address setr)
        Ownable(owner)
        SetInteroperable(setr)
        SetRemoteMintable(minter)
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(SetERC1155Compat, SetInteroperable, SetRemoteMintable)
        returns (bool)
    {
        return interfaceId == type(IRemoteMintable).interfaceId || interfaceId == type(IInteroperable).interfaceId
            || SetERC1155Compat.supportsInterface(interfaceId);
    }

    function _preCreate(uint64 id0, bytes32[] memory elems, address owner)
        internal
        virtual
        override
        returns (uint64 id, Descriptor memory desc)
    {}

    function _kindRevision(uint64 kindId, uint32 kindRev0) internal view virtual override returns (uint32) {}

    function _setRevision(uint64 setId, uint32 setRev0) internal view virtual override returns (uint32) {}

    function _uri() internal view virtual override returns (string memory) {}

    function _uri(uint64 id, uint32 rev) internal view virtual override returns (string memory) {}

    function _setURI() internal view virtual override returns (string memory) {}

    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        override
        returns (uint64 id)
    {}
}
