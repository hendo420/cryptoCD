//"SPDX-License-Identifier: UNLICENSED"

pragma solidity 0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract faucet {

    address public tokenAddress;
    mapping(address => uint) paidTime;
    uint frequency = 4 hours;
    address owner;
    
    constructor () public{
        owner = msg.sender;
    }
 
    function setTokenAddress(address _tokenAddress) public {
        require(msg.sender == owner);
        tokenAddress = _tokenAddress;
    }

    function tapFaucet() public {
        require(paidTime[msg.sender] <= now-frequency);
        paidTime[msg.sender] = now;
        uint _amount = IERC20(tokenAddress).balanceOf(address(this)) / 100;
        IERC20(tokenAddress).transfer(msg.sender, _amount);
        //msg.sender.transfer(address(this).balance/100);
    }
    
    function emptyFaucet() public {
        require(msg.sender == owner);
        uint _amount = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, _amount);
    }
}