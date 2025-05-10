// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking{

    address owner;
    address stakeToken;
    address rewardToken;
    uint  rewardRate = 3*10**13;
    uint lastUpdateTime;
    uint totalStakeToken;
    uint activeStakerCount;
    uint profitPerToken;

    struct staker{
        uint balanceStaker;
        uint userRewardPerToken;
        uint profit;
        uint withrowProfit;
    }

    mapping(address=>staker) stakerInfo;

    constructor(address st, address rt){
        stakeToken = st;
        rewardToken = rt;
    }

    //update and calc reward
    modifier  updateReward(address user){
        profitPerToken = calcProfit();
        lastUpdateTime = block.timestamp;
        stakerInfo[user].profit = earn(user);
        stakerInfo[user].userRewardPerToken= profitPerToken;
        _;
    }

    function calcProfit() public view returns(uint){
        if(totalStakeToken==0){
            return 0;
        }else{
            return profitPerToken + ((block.timestamp-lastUpdateTime)*rewardRate*1e18/totalStakeToken);
        }

    }

    function earn(address user) public view returns (uint){
        return (stakerInfo[user].profit+(stakerInfo[user].balanceStaker*(profitPerToken-stakerInfo[user].userRewardPerToken))/1e18);
    }

    //other modifir
    modifier checkBalance(uint amount){
        require(stakerInfo[msg.sender].balanceStaker>=amount, "balance is not enough...");
        _;
    }

    modifier checkRewardBalance{
        require(stakerInfo[msg.sender].profit>0, "you do not have any reward token...");
        _;
    }

    function stake(uint amount) public updateReward(msg.sender) returns(bool){
        if(stakerInfo[msg.sender].balanceStaker==0){
            activeStakerCount++;
        }
        stakerInfo[msg.sender].balanceStaker += amount;
        //already user should approve set for this.
        bool res = IERC20(stakeToken).transferFrom(msg.sender, address(this), amount);
        totalStakeToken += amount;
        return res;
    }

    function withdrow(uint amount) public checkBalance(amount) updateReward(msg.sender) returns(bool){
        stakerInfo[msg.sender].balanceStaker -= amount;
        if(stakerInfo[msg.sender].balanceStaker==0){
            activeStakerCount--;
        }
        bool res = IERC20(stakeToken).transfer(msg.sender, amount);
        totalStakeToken -= amount;
        return res;
    }

    function getReward() public checkRewardBalance updateReward(msg.sender) returns(bool){
        bool res = IERC20(rewardToken).transfer(msg.sender, stakerInfo[msg.sender].profit);
        stakerInfo[msg.sender].withrowProfit += stakerInfo[msg.sender].profit;
        stakerInfo[msg.sender].profit=0;
        return res;
    }

    function exit() public {
        withdrow(stakerInfo[msg.sender].balanceStaker);
        getReward();
        totalStakeToken--;
    }

    function getRewardRemind() public view returns(uint){
        return stakerInfo[msg.sender].profit;
    }

    function getAmountStaking() public view returns(uint){
         return stakerInfo[msg.sender].balanceStaker;
    }



}


