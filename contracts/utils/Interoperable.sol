// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ISoke} from "../interfaces/ISoke.sol";
import {ISetRegistry} from "../interfaces/core/ISetRegistry.sol";
import {Descriptor, IERC165, IInteroperable} from "../interfaces/user/IInteroperable.sol";
import {ISetRegistryAdmin} from "../interfaces/user/ISetRegistryAdmin.sol";

abstract contract Interoperable is IInteroperable, ISetRegistryAdmin {
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

    /// @inheritdoc ISetRegistryAdmin
    function registerSet(bytes32 data) external override onlySetOwner returns (uint64 id, Descriptor memory desc) {
        return ISetRegistry(_setRegistry).setRegister(data);
    }

    /// @inheritdoc ISetRegistryAdmin
    function updateSet(bytes32 data) external returns (uint64 id, Descriptor memory desc) {
        return ISetRegistry(_setRegistry).setUpdate(data);
    }

    /// @inheritdoc ISetRegistryAdmin
    function upgradeSet(uint32 kindRev0, uint32 setRev0) external returns (uint64 id, Descriptor memory desc) {
        return ISetRegistry(_setRegistry).setUpgrade(kindRev0, setRev0);
    }

    /// @inheritdoc ISetRegistryAdmin
    function touchSet() external returns (uint64 id, Descriptor memory desc) {
        return ISetRegistry(_setRegistry).setTouch();
    }

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

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool supported) {
        return interfaceId == type(IInteroperable).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
