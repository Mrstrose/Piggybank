// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract PiggyBank{
    address public immutable owner;
    bool public closed;
    uint public target;
    uint public timeGoal;

    event Deposit( uint indexed amount);
    event Withdraw(uint indexed amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }
    
    constructor(uint _timeGoal, uint _target) {
        owner = msg.sender;
        timeGoal = _timeGoal;
        target = _target;
    }

    receive() external payable { 
        require(!closed, "Piggy Closed");
        emit Deposit(msg.value);
    }
    
    function closeContract() internal {
        closed = true;
    }

    function _withdraw() internal {
        require(msg.sender == owner, "Not Authorized");

        // selfdestruct(payable(msg.sender));

        uint balance = address(this).balance;
        require(balance > 0, "Balance is zero");
        require(block.timestamp >= timeGoal, "Too early");
        require(balance >= target, "target not met");

        emit Withdraw(balance);

        (bool sent, ) = owner.call{value : balance}("");
        require(sent, "transfer failed");

    }

    function withdraw() external onlyOwner {
        _withdraw();
        closeContract();
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}