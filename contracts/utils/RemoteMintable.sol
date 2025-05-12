// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IObjectMinter, MintPolicy} from "../interfaces/core/IObjectMinter.sol";
import {IObjectMinterAdmin} from "../interfaces/user/IObjectMinterAdmin.sol";
import {IERC165, IRemoteMintable} from "../interfaces/user/IRemoteMintable.sol";

abstract contract RemoteMintable is IRemoteMintable, IObjectMinterAdmin {
    error InvalidObjectMinterAddress();
    error ObjectIdNotSpecified();
    error CallerNotObjectMinter();

    address internal _objectMinter;

    modifier onlyObjectMinter() {
        if (msg.sender != _objectMinter) revert CallerNotObjectMinter();
        _;
    }

    modifier onlySetOwner() virtual;

    constructor(address minter) {
        if (minter == address(0)) revert InvalidObjectMinterAddress();
        _objectMinter = minter;
    }

    /// @inheritdoc IObjectMinterAdmin
    function addMintPolicy(MintPolicy memory policy) external override onlySetOwner returns (uint32 index) {
        index = IObjectMinter(_objectMinter).mintPolicyAdd(policy);
    }

    /// @inheritdoc IObjectMinterAdmin
    function disableMintPolicy(uint32 index) external override onlySetOwner {
        IObjectMinter(_objectMinter).mintPolicyDisable(index);
    }

    /// @inheritdoc IObjectMinterAdmin
    function enableMintPolicy(uint32 index) external override onlySetOwner {
        IObjectMinter(_objectMinter).mintPolicyEnable(index);
    }

    /// @inheritdoc IRemoteMintable
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        override
        onlyObjectMinter
        returns (bytes4 supported, uint64 id)
    {
        id = _mint(operator, to, id0, context, data);
        supported = this.onObjectMint.selector;
    }

    /// @inheritdoc IRemoteMintable
    function objectMinter() external view override returns (address) {
        return _objectMinter;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool) {
        return interfaceId == type(IRemoteMintable).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function _mint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        internal
        virtual
        returns (uint64 id);
}
