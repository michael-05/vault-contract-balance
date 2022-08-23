// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultContract is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    constructor() {}

    // vault[tokenAddress][depositorAddress]
    mapping(address => mapping(address => uint256)) public vault;
    mapping(address => address[]) private depositors;

    function deposit(address _token, uint256 _amount) external nonReentrant {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        vault[_token][msg.sender] += _amount;
        depositors[_token].push(msg.sender);
    }

    function withdraw(address _token, uint256 _amount) external nonReentrant {
        require(
            vault[_token][msg.sender] >= _amount,
            "Not enough tokens to withdraw."
        );
        IERC20(_token).safeTransfer(msg.sender, _amount);

        vault[_token][msg.sender] -= _amount;
        if (vault[_token][msg.sender] == 0) {
            uint256 indexOfWithdrawer = findWithdrawerIndex(_token, msg.sender);
            depositors[_token][indexOfWithdrawer] = depositors[_token][
                depositors[_token].length - 1
            ];
            depositors[_token].pop();
        }
    }

    function findWithdrawerIndex(address _token, address _withdrawer)
        private
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < depositors[_token].length; i++) {
            if (depositors[_token][i] == _withdrawer) {
                return i;
            }
        }
        return 0;
    }

    function twoWealthies(address _token)
        external
        view
        returns (
            address top1Address,
            uint256 top1Amount,
            address top2Address,
            uint256 top2Amount
        )
    {
        require(depositors[_token].length >= 2, "No more than two depositors.");

        for (uint256 i = 0; i < depositors[_token].length; i++) {
            address curAddress = depositors[_token][i];
            uint256 curAmount = vault[_token][curAddress];

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
