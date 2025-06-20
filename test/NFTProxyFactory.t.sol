// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {NFTProxyFactory} from "../src/NFTProxyFactory.sol";
import {NFTImplementation} from "../src/NFTImplementation.sol";
import {INFTImplementation} from "../src/interfaces/INFTImplementation.sol";

contract NFTProxyFactoryTest is Test {
    NFTProxyFactory public nftProxyFactory;
    address public implementation;
    address public proxy;
    address public owner;

    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);

        implementation = address(new NFTImplementation());
        nftProxyFactory = new NFTProxyFactory(implementation);
        proxy = nftProxyFactory.deployClone("First NFT", "FNFT");
        INFTImplementation(proxy).mint(owner, "https://example.com");

        assertEq(INFTImplementation(proxy).name(), "First NFT");
        assertEq(INFTImplementation(proxy).symbol(), "FNFT");
        assertEq(INFTImplementation(proxy).tokenURI(0), "https://example.com");
        assertEq(INFTImplementation(proxy).ownerOf(0), owner);

        vm.stopPrank();
    }

    function test_burn() public {
        vm.startPrank(owner);
        INFTImplementation(proxy).burn(0);
        assertEq(INFTImplementation(proxy).balanceOf(owner), 0);
        vm.stopPrank();
    }

    function test_setTokenURI() public {
        address notOwner = makeAddr("notOwner");
        vm.startPrank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(NFTImplementation.NotOwner.selector));
        INFTImplementation(proxy).setTokenURI(0, "https://example.com/new");

        vm.startPrank(owner);
        INFTImplementation(proxy).setTokenURI(0, "https://example.com/new");
        assertEq(INFTImplementation(proxy).tokenURI(0), "https://example.com/new");
        vm.stopPrank();
    }
}
