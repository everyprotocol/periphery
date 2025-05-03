// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IUniqueRegistry} from "./IUniqueRegistry.sol";
import {IValueRegistry} from "./IValueRegistry.sol";

/**
 * @title IElementRegistry
 * @notice Element registration and management
 */
interface IElementRegistry is IValueRegistry, IUniqueRegistry {}
