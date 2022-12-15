//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact siriwat576@gmail.com
contract NativeERC721 is
    ERC721,
    AccessControl,
    ERC721URIStorage,
    ERC721Enumerable,
    Pausable,
    Multicall
{
    event URI(string value);
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    mapping(uint256=>uint256) private _tokenFlag;
    mapping(uint256=>bool) private _useTokenURI;
    Counters.Counter private _tokenIdCounter;

    string private _baseTokenURI = "";
    bool private _useOnlyBaseURI = false;
    uint256 private _startTokenId = 0;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    function setStartTokenId(uint256 _startIndex) external onlyRole(MINTER_ROLE) {
        _startTokenId = _startIndex;
    }

    function setUseOnlyBaseURI(bool _toggle) external onlyRole(MINTER_ROLE) {
        require(_useOnlyBaseURI != _toggle, "ERC721: Duplicated value");

        _useOnlyBaseURI = _toggle;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory uri) external onlyRole(MINTER_ROLE) {
        require(bytes(uri).length > 0, "ERC721: Invalid URI");

        _baseTokenURI = uri;
        emit URI(_baseURI());
    }

    function mintWithURI(address to, string memory uri) external onlyRole(MINTER_ROLE) returns(uint256) {
        require(bytes(uri).length > 0, "ERC721: Invalid uri");

        uint256 tokenId = pureMint(to);
        _setTokenURI(tokenId, uri);
        _useTokenURI[tokenId] = true;
        return tokenId;
    }

    function setTokenFlag(uint256 tokenId, uint256 flag) external onlyRole(MINTER_ROLE) {
        _tokenFlag[tokenId] = flag;
    }

    function getTokenFlag(uint256 tokenId) external view returns(uint256) {
        return _tokenFlag[tokenId];
    }

    function pureMint(address to) public onlyRole(MINTER_ROLE) returns(uint256) {
        require(to != address(0) && to != address(this), "ERC721: Invalid address");

        uint256 tokenId = _startTokenId + _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _useTokenURI[tokenId] = false;
        return tokenId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function burn(uint256 tokenId) public onlyRole(BURNER_ROLE) {
        require(
            address(0) != ownerOf(tokenId) &&
            address(this) != ownerOf(tokenId),
            "ERC721: Invalid owner"
        );

        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        if(_useOnlyBaseURI && !_useTokenURI[tokenId]) return _baseURI();
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}