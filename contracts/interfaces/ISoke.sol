// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title ISoke
 * @notice Interface for accessing the core registry contracts
 */
interface ISoke {
    /**
     * @notice Returns the address of the Set Registry contract
     * @return setr Address of the Set Registry
     */
    function setRegistry() external view returns (address setr);

    /**
     * @notice Returns the address of the Omni Registry contract
     * @return omnir Address of the Omni Registry
     */
    function omniRegistry() external view returns (address omnir);

    /**
     * @notice Returns the address of the Kind Registry contract
     * @return kindr Address of the Kind Registry
     */
    function kindRegistry() external view returns (address kindr);

    /**
     * @notice Returns the address of the Element Registry contract
     * @return elemr Address of the Element Registry
     */
    function elementRegistry() external view returns (address elemr);
}
