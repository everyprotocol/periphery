// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IObjectMinter} from "../interfaces/core/IObjectMinter.sol";
import {IERC165, IRemoteMintable} from "../interfaces/user/IRemoteMintable.sol";

abstract contract SetRemoteMintable is IRemoteMintable {
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

    function addMintPolicy(IObjectMinter.MintPolicy memory policy) external onlySetOwner returns (uint32 index) {
        index = IObjectMinter(_objectMinter).mintPolicyAdd(policy);
    }

    function disableMintPolicy(uint32 index) external onlySetOwner {
        IObjectMinter(_objectMinter).mintPolicyDisable(index);
    }

    function enableMintPolicy(uint32 index) external onlySetOwner {
        IObjectMinter(_objectMinter).mintPolicyEnable(index);
    }

    /// @inheritdoc IRemoteMintable
    function onObjectMint(address operator, address to, uint64 id0, uint256 context, bytes memory data)
        external
        override
        onlyObjectMinter
        returns (bytes4 supported, uint64 id)
    {
        if (id0 == 0) revert ObjectIdNotSpecified();
        id = id0;
        context; // slience warning;
        operator; // slience warning;
        // bytes32[] memory elements = data.length == 0 ? new bytes32[](0) : abi.decode(data, (bytes32[]));
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
