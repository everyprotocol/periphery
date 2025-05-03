// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISoke} from "../interfaces/ISoke.sol";
import {ISetRegistry} from "../interfaces/core/ISetRegistry.sol";
import {Descriptor, IERC165, IInteroperable} from "../interfaces/user/IInteroperable.sol";

abstract contract SetInteroperable is IInteroperable {
    error InvalidRegistryAddress();
    error CallerNotSetRegistry();
    error CallerNotOmniRegistry();

    address internal _setRegistry;
    address internal _omniRegistry;
    address internal _kindRegistry;
    address internal _elemRegistry;

    uint64 internal _setId;
    uint32 internal _setRev;

    modifier onlySetRegistry() {
        if (msg.sender != _setRegistry) revert CallerNotSetRegistry();
        _;
    }

    modifier onlyOmniRegistry() {
        if (msg.sender != _omniRegistry) revert CallerNotOmniRegistry();
        _;
    }

    modifier onlySetOwner() virtual;

    constructor(address setr) {
        _setRegistry = setr;
        _omniRegistry = ISoke(setr).omniRegistry();
        _kindRegistry = ISoke(setr).kindRegistry();
        _elemRegistry = ISoke(setr).elementRegistry();
    }

    function registerSet() external onlySetOwner {
        ISetRegistry(_setRegistry).setRegister(bytes32("data"));
    }

    // function mint(address to, uint64 id, bytes32[] memory elements) external onlyOwner {
    //     _create(id, elements, to);
    // }

    // function update(uint64 id, bytes32[] memory elements) external onlyHolder(id) {
    //     _update(id, elements);
    // }

    // function upgradeKind(uint32 kindRev) external onlyOwner {
    //     if (kindRev <= _kindRev) revert InvalidKindRevision();
    //     _kindRev = kindRev;
    // }

    /// @inheritdoc IInteroperable
    function onSetRegister(uint64 set, Descriptor memory meta)
        external
        virtual
        override
        onlySetRegistry
        returns (bytes4)
    {
        _setId = set;
        _setRev = meta.rev;
        return this.onSetRegister.selector;
    }

    /// @inheritdoc IInteroperable
    function onSetUpdate(uint64 set, Descriptor memory meta)
        external
        virtual
        override
        onlySetRegistry
        returns (bytes4)
    {
        set; // Silence unused variable warning
        _setRev = meta.rev;
        return this.onSetUpdate.selector;
    }

    /// @inheritdoc IInteroperable
    function onSetUpgrade(uint64 set, Descriptor memory meta)
        external
        virtual
        override
        onlySetRegistry
        returns (bytes4)
    {
        set; // Silence unused variable warning
        _setRev = meta.rev;
        return this.onSetUpgrade.selector;
    }

    /// @inheritdoc IInteroperable
    function onSetTouch(uint64 set, Descriptor memory meta)
        external
        virtual
        override
        onlySetRegistry
        returns (bytes4)
    {
        set; // Silence unused variable warning
        _setRev = meta.rev;
        return this.onSetTouch.selector;
    }

    /// @inheritdoc IInteroperable
    function onObjectTouch(uint64 id) external virtual override onlyOmniRegistry returns (bytes4, uint32) {
        return (this.onObjectTouch.selector, 0);
    }

    /// @inheritdoc IInteroperable
    function onObjectRelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        virtual
        override
        onlyOmniRegistry
        returns (Descriptor memory meta)
    {
        return meta;
    }

    /// @inheritdoc IInteroperable
    function onObjectUnrelate(uint64 id, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
        external
        virtual
        override
        onlyOmniRegistry
        returns (Descriptor memory meta)
    {
        return meta;
    }

    /// @inheritdoc IInteroperable
    function onObjectTransfer(uint64 id, address from, address to)
        external
        virtual
        override
        onlyOmniRegistry
        returns (bytes4)
    {
        return this.onObjectTransfer.selector;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool supported) {
        return interfaceId == type(IInteroperable).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    // function onObjectRelate(uint64 headId, uint64 rel, uint64 data, uint64 tailSet, uint64 tailId, uint64 tailKind)
    //     external
    //     override
    //     onlyOmniRegistry
    //     returns (Descriptor memory meta)
    // {
    //     meta = _touchNoEmit(headId);
    //     _afterStateChange(headId, meta.rev);
    //     return meta;
    // }
}
