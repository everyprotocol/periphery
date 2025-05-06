// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IObjectAuthorization} from "./IObjectAuthorization.sol";
import {IObjectInteraction} from "./IObjectInteraction.sol";
import {IRelationRegistry} from "./IRelationRegistry.sol";

/// @title IOmniRegistry
/// @notice Interface for object interactions
interface IOmniRegistry is IRelationRegistry, IObjectAuthorization, IObjectInteraction {}
