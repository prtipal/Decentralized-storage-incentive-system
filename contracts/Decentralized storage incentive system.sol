// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DecentralizedStorageIncentive
 * @dev A system rewarding users for providing storage resources
 */
contract Project {
    address public owner;
    uint256 public rewardRatePerGBPerDay; // in wei per GB per day

    struct Provider {
        uint256 storageProvidedGB;
        uint256 lastClaimTimestamp;
        uint256 totalEarned;
    }

    mapping(address => Provider) public providers;

    event StorageRegistered(address indexed provider, uint256 storageGB);
    event RewardClaimed(address indexed provider, uint256 amount);
    event RewardRateUpdated(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(uint256 _rewardRatePerGBPerDay) {
        owner = msg.sender;
        rewardRatePerGBPerDay = _rewardRatePerGBPerDay;
    }

    function registerStorage(uint256 _storageGB) external {
        require(_storageGB > 0, "Storage must be > 0");

        Provider storage provider = providers[msg.sender];

        // If new registration, set lastClaimTimestamp to now
        if (provider.storageProvidedGB == 0) {
            provider.lastClaimTimestamp = block.timestamp;
        } else {
            // Claim rewards till now before updating storage amount
            claimRewards();
        }

        provider.storageProvidedGB = _storageGB;
        emit StorageRegistered(msg.sender, _storageGB);
    }

    function claimRewards() public {
        Provider storage provider = providers[msg.sender];
        require(provider.storageProvidedGB > 0, "No storage registered");

        uint256 elapsedTime = block.timestamp - provider.lastClaimTimestamp;
        require(elapsedTime > 0, "No rewards to claim yet");

        // Calculate rewards: rewardRatePerGBPerDay * storageGB * elapsedDays
        uint256 elapsedDays = elapsedTime / 1 days;
        require(elapsedDays > 0, "Minimum 1 day required to claim rewards");

        uint256 reward = rewardRatePerGBPerDay * provider.storageProvidedGB * elapsedDays;

        provider.lastClaimTimestamp += elapsedDays * 1 days;
        provider.totalEarned += reward;

        // Transfer rewards (assumes contract is funded with Ether)
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function updateRewardRate(uint256 _newRate) external onlyOwner {
        rewardRatePerGBPerDay = _newRate;
        emit RewardRateUpdated(_newRate);
    }

    // Fund the contract to pay rewards
    receive() external payable {}

    function getProviderInfo(address _provider) external view returns (
        uint256 storageProvidedGB,
        uint256 lastClaimTimestamp,
        uint256 totalEarned
    ) {
        Provider memory provider = providers[_provider];
        return (provider.storageProvidedGB, provider.lastClaimTimestamp, provider.totalEarned);
    }
}
