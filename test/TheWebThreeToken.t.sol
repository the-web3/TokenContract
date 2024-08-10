// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/TheWebThreeToken.sol";

contract DappLinkTokenTest is Test {
    TheWebThreeToken public theWebThreeToken;

    function setUp() public {
        theWebThreeToken = new TheWebThreeToken();
    }

    function testMint() public {
    }

    function testSetMintCapNumerator(uint256 x) public {
    }
}
