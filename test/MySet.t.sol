// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MySet} from "../contracts/examples/MySet.sol";
import "forge-std/Test.sol";

contract MySet_Test is Test {
    MySet mySet;

    function setUp() public {
        mySet = new MySet(makeAddr("SetRegistry"), 17, 1);
    }

    function test_Foo() public {
        // todo!
    }
}
