// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenS.sol";
import "./TokenC.sol";

contract Staking {
    address tokenS;
    address tokenC;
    uint pureProfit = 3*1e13;
    uint numholder;
    uint totalStaking;
    uint lastTime;
    uint profitPertoken;
    struct stake{
        uint totalProfit;
        uint amount; 
        uint giveProfit; 
        uint rewardperToken; 
        bool first;    
    }
    mapping (address => stake) staking;

    constructor(address TS, address TC){
        tokenS = TS;
        tokenC = TC;
    }

    function stakeT(uint amount) public {
        updateProfit(msg.sender);
        staking[msg.sender].amount += amount; 
        totalStaking += amount;
        if(!staking[msg.sender].first) {
            staking[msg.sender].first = true;
            numholder++;
        }
        bool r = IERC20(tokenS).transferFrom(msg.sender, address(this), amount); 
        require(r,"transfer faild");           
    }

    function calcProfit() public {
        if(totalStaking!=0){
            profitPertoken = (block.timestamp - lastTime)*pureProfit*1e18/totalStaking;
        }
    }

    function updateProfit(address s) public {
        calcProfit();
        lastTime = block.timestamp;
        staking[s].totalProfit += earn(s);
        staking[s].rewardperToken;

    }

    function earn(address s) public view returns(uint){
        return (staking[s].amount*(staking[s].rewardperToken-profitPertoken))/1e18;

    }

    modifier checkBalance(uint amount, address s){
        require(amount <= staking[s].amount,"yout balance not enough");
        _;
    }

    function witdrow(uint amount) public checkBalance(amount, msg.sender){
        updateProfit(msg.sender);
        staking[msg.sender].amount -= amount;
        totalStaking -= amount;
        if(staking[msg.sender].amount == 0){
            numholder--;
        }
        bool r = IERC20(tokenS).transfer(msg.sender, amount);
        require(r,"the transfer faild");

    }

    modifier checkRewardBalance(uint amount, address s){
        require(amount <= staking[s].totalProfit,"the amount there is not");
        _;
    }

    function getReward(uint amount) public checkRewardBalance(amount, msg.sender){
        updateProfit(msg.sender);
        staking[msg.sender].totalProfit -= amount;
        staking[msg.sender].giveProfit += amount;
        bool r = IERC20(tokenC).transfer(msg.sender,amount);
        require(r, "the transfer faild");
    }

    

}