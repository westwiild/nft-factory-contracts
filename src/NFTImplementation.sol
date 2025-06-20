// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFTImplementation is ERC721Upgradeable, OwnableUpgradeable {
    /// @notice tokenId is used to track the number of tokens minted
    uint256 public tokenId;
    /// @notice The Token URI for the token metadata.
    mapping(uint256 tokenId => string tokenURI) public metadata;

    error NotOwner();

    /**
     * @dev Initializes the contract by setting a name and a symbol to the token collection.
     * @param name The name of the token collection.
     * @param symbol The symbol of the token collection.
     */
    function initialize(string memory name, string memory symbol, address _owner) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(_owner);
    }

    /**
     * @dev Mints a new token to the specified address.
     * @param to The address to mint the token to.
     */
    function mint(address to, string memory _tokenURI) public onlyOwner {
        _safeMint(to, tokenId);
        metadata[tokenId] = _tokenURI;
        tokenId++;
    }

    /**
     * @dev Burns a token.
     * @param _tokenId The ID of the token to burn.
     */
    function burn(uint256 _tokenId) public {
        _burn(_tokenId);
    }

    /**
     * @dev Sets the token URI for a specific token ID.
     * @param _tokenId The ID of the token to set the URI for.
     * @param _tokenURI The URI to set for the token.
     */
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
        if (msg.sender != ownerOf(_tokenId)) {
            revert NotOwner();
        }
        metadata[_tokenId] = _tokenURI;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     * @param _tokenId The ID of the token to get the URI for.
     * @return The URI of the token.
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireOwned(_tokenId);
        return metadata[_tokenId];
    }
}
