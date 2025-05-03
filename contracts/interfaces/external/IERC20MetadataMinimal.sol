// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC20MetadataMinimal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
