// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC7572 {
    event ContractURIUpdated();

    function contractURI() external view returns (string memory);
}
