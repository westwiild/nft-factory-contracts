// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFTImplementation is IERC721 {
    function initialize(string memory name, string memory symbol, address _owner) external;
    function mint(address to, string memory tokenURI) external;
    function burn(uint256 tokenId) external;
    function setTokenURI(uint256 tokenId, string memory tokenURI) external;

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
