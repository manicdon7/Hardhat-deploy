// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YieldingAndLendingContract is Ownable(address(this)) {
    IERC20 public stakingToken; // Token used for staking/lending
    uint256 public totalStaked; // Total staked tokens
    uint256 public totalLent; // Total lent tokens
    uint256 public rewardRate; // Reward rate per token per day
    uint256 public interestRate; // Borrow interest rate (annual percentage)

    struct Loan {
        uint256 amount; // Borrowed amount
        uint256 collateral; // Locked collateral
        uint256 borrowedAt; // Timestamp of loan creation
    }

    mapping(address => uint256) public balances; // User's staked balance
    mapping(address => uint256) public rewards;  // User's accumulated rewards
    mapping(address => uint256) public lastUpdated; // Last time rewards were updated
    mapping(address => Loan) public loans; // User's loan details

    uint256 constant SECONDS_IN_A_YEAR = 31536000;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event LoanTaken(address indexed user, uint256 amount, uint256 collateral);
    event LoanRepaid(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRewardRate);
    event InterestRateUpdated(uint256 newInterestRate);

    constructor(address _stakingToken, uint256 _rewardRate, uint256 _interestRate) {
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
        interestRate = _interestRate;
    }

    // Modifier to update rewards before any operation
    modifier updateReward(address account) {
        if (account != address(0)) {
            rewards[account] = calculateReward(account);
            lastUpdated[account] = block.timestamp;
        }
        _;
    }

    // Stake tokens to earn rewards
    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Amount must be greater than 0");
        stakingToken.transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    // Withdraw staked tokens with rewards
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        totalStaked -= amount;

        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;

        stakingToken.transfer(msg.sender, amount + reward);

        emit Withdrawn(msg.sender, amount);
        emit RewardClaimed(msg.sender, reward);
    }

    // Claim only rewards
    function claimRewards() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards available");

        rewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    // Borrow tokens against collateral
    function borrow(uint256 amount, uint256 collateral) external {
        require(collateral >= (amount * 150) / 100, "Collateral must be at least 150% of loan"); // 150% collateralization
        stakingToken.transferFrom(msg.sender, address(this), collateral);

        loans[msg.sender] = Loan(amount, collateral, block.timestamp);
        totalLent += amount;

        stakingToken.transfer(msg.sender, amount);

        emit LoanTaken(msg.sender, amount, collateral);
    }

    // Repay loan and retrieve collateral
    function repayLoan() external {
        Loan memory loan = loans[msg.sender];
        require(loan.amount > 0, "No active loan");

        uint256 interest = calculateInterest(loan.amount, loan.borrowedAt);
        uint256 repaymentAmount = loan.amount + interest;

        stakingToken.transferFrom(msg.sender, address(this), repaymentAmount);

        uint256 collateralToReturn = loan.collateral;
        delete loans[msg.sender];
        totalLent -= loan.amount;

        stakingToken.transfer(msg.sender, collateralToReturn);

        emit LoanRepaid(msg.sender, repaymentAmount);
    }

    // Calculate rewards
    function calculateReward(address account) public view returns (uint256) {
        uint256 userStake = balances[account];
        uint256 timeStaked = block.timestamp - lastUpdated[account];

        uint256 dailyReward = (userStake * rewardRate) / 100;
        uint256 reward = (dailyReward * timeStaked) / 86400;

        return rewards[account] + reward;
    }

    // Calculate interest on a loan
    function calculateInterest(uint256 amount, uint256 borrowedAt) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - borrowedAt;
        uint256 annualInterest = (amount * interestRate) / 100;

        return (annualInterest * timeElapsed) / SECONDS_IN_A_YEAR;
    }

    // Set reward rate (only owner)
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }

    // Set interest rate (only owner)
    function setInterestRate(uint256 _interestRate) external onlyOwner {
        interestRate = _interestRate;
        emit InterestRateUpdated(_interestRate);
    }
}
