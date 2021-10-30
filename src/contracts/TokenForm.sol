pragma solidity >=0.4.22 <0.9.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;
    address public owner;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    address[] public stackers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // 1. Stack tokens (Deposit)
    function stackTokens(uint256 _amount) public {
        require(_amount > 0);

        // Transfer Mock DAI tokens to contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] += _amount;

        // Add user to stackers array only if they have not already staked
        if (!hasStaked[msg.sender]) {
            stackers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        isStaking[msg.sender] = true;
    }

    // 2. Unstaking tokens (Withdraw)
    function unstackTokens() public {
        uint256 balance = stakingBalance[msg.sender];

        require(balance >= 0);

        // unstack tokens from contract to dai token
        daiToken.transfer(msg.sender, balance);

        // update staking balance
        stakingBalance[msg.sender] = 0;

        // remove user from stackers array
        isStaking[msg.sender] = false;
    }

    // 3. Issuing tokens (Gain interest)
    function issueTokens() public {
        require(msg.sender == owner);

        for (uint256 i = 0; i < stackers.length; i++) {
            address recipient = stackers[i];
            uint256 balance = stakingBalance[recipient];

            if (balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }
}
