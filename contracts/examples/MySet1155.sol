// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ObjectIdAuto} from "@everyprotocol/periphery/libraries/Allocator.sol";
import {Descriptor, ERC1155Compatible, ISet} from "@everyprotocol/periphery/utils/ERC1155Compatible.sol";
import {ISetRegistry, SetRegistryAdmin} from "@everyprotocol/periphery/utils/SetRegistryAdmin.sol";
import {ISetRegistryHook, SetContext, SetRegistryHook} from "@everyprotocol/periphery/utils/SetRegistryHook.sol";

contract MySet1155 is ERC1155Compatible, SetRegistryHook, SetRegistryAdmin {
    error KindRevNotSpecified();

    ObjectIdAuto.Storage internal _idAllocator;

    constructor(address setRegistry, uint64 kindId, uint32 kindRev) SetRegistryHook(setRegistry) {
        if (kindRev == 0) revert KindRevNotSpecified();
        SetContext.setKindId(kindId);
        SetContext.setKindRev(kindRev);
    }

    // function create(address to, uint64 id0, bytes calldata data)
    //     external
    //     override
    //     returns (uint64 id, Descriptor memory od)
    // {
    //     (bytes32[] memory elems) = abi.decode(data, (bytes32[]));
    //     id = ObjectIdAuto.allocate(_idAllocator, id0);
    //     od = Descriptor(
    //         0, 1, SetContext.getSetRev(), SetContext.getSetRev(), SetContext.getKindId(), SetContext.getSetId()
    //     );
    //     _create(id, od, elems, to);
    //     _postCreate(id, od, elems, to);
    // }
    //
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override(ERC1155Compatible, SetRegistryHook)
        returns (bool)
    {
        return (interfaceId == type(ISetRegistryHook).interfaceId) || ERC1155Compatible._supportsInterface(interfaceId);
    }

    function _objectURI() internal view virtual override returns (string memory) {
        return ISetRegistry(SetContext.getSetRegistry()).setURI(SetContext.getSetId());
    }

    function _tokenURI(uint64 id, uint32 rev) internal view virtual override returns (string memory) {}

    function _contractURI() internal view virtual override returns (string memory) {}
}
