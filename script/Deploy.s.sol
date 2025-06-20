// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {NFTProxyFactory} from "../src/NFTProxyFactory.sol";
import {NFTImplementation} from "../src/NFTImplementation.sol";
import {INFTImplementation} from "../src/interfaces/INFTImplementation.sol";

contract Deploy is Script {
    function run() external returns (address, address, address) {
        vm.startBroadcast();

        address implementation = address(new NFTImplementation());
        console.log("NFTImplementation deployed at", implementation);

        NFTProxyFactory nftProxyFactory = new NFTProxyFactory(implementation);
        console.log("NFTProxyFactory deployed at", address(nftProxyFactory));

        address proxy = nftProxyFactory.deployClone("First NFT", "FNFT");
        console.log("NFTProxy deployed at", proxy);

        INFTImplementation(proxy).mint(msg.sender, "https://example.com");
        console.log("Token minted to", msg.sender);

        vm.stopBroadcast();
        return (implementation, address(nftProxyFactory), proxy);
    }
}
