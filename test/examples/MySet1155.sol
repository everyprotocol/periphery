// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Descriptor, SetERC1155Compat} from "@periphery/sets/SetERC1155Compat.sol";
// ai! implement, see MySeetMinimal.sol for example

contract MySet1155 is SetERC1155Compat {
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
}
