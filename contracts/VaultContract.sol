// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultContract is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor() {}

    // vault[tokenAddress][depositorAddress]
    mapping(address => mapping(address => uint256)) public vault;
    mapping(address => address[]) depositors;

    function deposit(IERC20 _token, uint256 _amount) external {
        require(
            _token.allowance(msg.sender, address(this)) >= _amount,
            "Approve tokens first!"
        );
        _token.safeTransferFrom(msg.sender, address(this), _amount);

        vault[address(_token)][msg.sender] = vault[address(_token)][msg.sender]
            .add(_amount);
        depositors[address(_token)].push(msg.sender);
    }

    function withdraw(IERC20 _token) external {
        require(
            vault[address(_token)][msg.sender] > 0,
            "No tokens to withdraw."
        );
        _token.safeTransfer(msg.sender, vault[address(_token)][msg.sender]);

        vault[address(_token)][msg.sender] = 0;
        uint256 indexOfWithdrawer = findWithdrawerIndex(
            address(_token),
            msg.sender
        );
        depositors[address(_token)][indexOfWithdrawer] = depositors[
            address(_token)
        ][depositors[address(_token)].length - 1];
        delete depositors[address(_token)][
            depositors[address(_token)].length - 1
        ];
    }

    function findWithdrawerIndex(address tokenAddress, address withdrawer)
        public
        view
        returns (uint256)
    {
        uint256 len = depositors[tokenAddress].length;
        for (uint256 i = 0; i < len; i++) {
            if (depositors[tokenAddress][i] == withdrawer) {
                return i;
            }
        }
        return 0;
    }

    function twoWealthies(IERC20 _token)
        external
        view
        returns (
            address top1Address,
            uint256 top1Amount,
            address top2Address,
            uint256 top2Amount
        )
    {
        address tokenAddress;
        tokenAddress = address(_token);
        uint256 len = depositors[tokenAddress].length;
        for (uint256 i = 0; i < len; i++) {
            address curAddress = depositors[tokenAddress][i];
            uint256 curAmount = vault[tokenAddress][curAddress];

            if (curAmount > top1Amount) {
                top2Amount = top1Amount;
                top2Address = top1Address;

                top1Amount = curAmount;
                top1Address = curAddress;
            } else if (curAmount > top2Amount) {
                top2Amount = curAmount;
                top2Address = curAddress;
            }
        }
    }
}
