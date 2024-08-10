// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console} from "forge-std/Script.sol";
import "../src/TheWebThreeToken.sol";

/*
forge script script/TheWebThreeToken.s.sol:TheWebThreeTokenScript --rpc-url http://127.0.0.1:8545 --private-key ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  --broadcast -vvvv
*/
contract TheWebThreeTokenScript is Script {
    ProxyAdmin public theWebThreeProxyAdmin;
    TheWebThreeToken public theWebThreeToken;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        uint256 totalSupply = 1000000000 * 1e18;

        vm.startBroadcast(deployerPrivateKey);

        theWebThreeProxyAdmin = new ProxyAdmin(deployerAddress);
        console.log("The Web3 ProxyAdmin:", address(theWebThreeProxyAdmin));

        theWebThreeToken = new TheWebThreeToken();

        TransparentUpgradeableProxy proxyTheWebThreeTokenn = new TransparentUpgradeableProxy(
            address(theWebThreeToken),
            address(theWebThreeProxyAdmin),
            abi.encodeWithSelector(TheWebThreeToken.initialize.selector, totalSupply, deployerAddress)
        );
        console.log("TransparentUpgradeableProxy deployed at:", address(proxyTheWebThreeTokenn));

        vm.stopBroadcast();
    }
}
