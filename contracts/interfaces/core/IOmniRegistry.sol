// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IObjectAuthorization} from "./IObjectAuthorization.sol";
import {IObjectInteraction} from "./IObjectInteraction.sol";
import {IRelationRegistry} from "./IRelationRegistry.sol";

/**
 * @title IOmniRegistry
 * @notice Manages relation registration and object interactions through relations.
 *
 */
interface IOmniRegistry is IRelationRegistry, IObjectAuthorization, IObjectInteraction {}
