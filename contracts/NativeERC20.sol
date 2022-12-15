//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @custom:security-contact siriwat576@gmail.com
contract NativeERC20 is ERC20Capped, AccessControl, ERC20Snapshot, Multicall {

    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(string memory name, string memory symbol, uint256 maxSupply) ERC20(name, symbol) ERC20Capped(maxSupply) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SNAPSHOT_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Capped){
        super._mint(to, amount);
    }

    function mint(address _to, uint256 _amount) external virtual onlyRole(MINTER_ROLE){
        require(address(0) != _to && address(this) != _to, "Token: Invalid address");
        require(_amount > 0, "Token: Invalid amount");

        _mint(_to, _amount);
    }

    function burn(address _account, uint256 _amount) external onlyRole(BURNER_ROLE) {
        require(
            address(0) != _account &&
            address(this) != _account,
            "ERC20: Invalid owner"
        );
        require(_amount > 0, "ERC20: Invalid amount");

        _burn(_account, _amount);
    }
}