// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";

/**
 * @title VotingSystem
 * @dev 一个简单的可升级投票系统合约
 * @notice 这个合约允许创建提案并对其进行投票
 */
contract VotingSystem is Initializable, OwnableUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    // 存储变量 - 注意可升级合约的存储布局
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        uint256 endTime;
    }

    // 记录提案
    Proposal[] internal s_proposals;

    // 记录投票
    mapping(address => mapping(uint256 => bool)) internal s_hasVoted;

    // 版本号，用于追踪合约版本
    uint256 internal s_version;

    // 事件
    event ProposalCreated(uint256 indexed proposalId, string description, uint256 endTime);
    event Voted(address indexed voter, uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev 初始化函数，替代constructor
     * @param initialOwner 合约的初始所有者
     */
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __Pausable_init();
        s_version = 1;
    }

    /**
     * @dev 创建一个新的提案
     * @param description 提案的描述
     * @param votingPeriod 投票持续的时间（以秒为单位）
     */
    function createProposal(string calldata description, uint256 votingPeriod) external onlyOwner whenNotPaused {
        uint256 endTime = block.timestamp + votingPeriod;
        s_proposals.push(Proposal({
            description: description,
            voteCount: 0,
            executed: false,
            endTime: endTime
        }));

        emit ProposalCreated(s_proposals.length - 1, description, endTime);
    }

    /**
     * @dev 对提案进行投票
     * @param proposalId 提案的ID
     */
    function vote(uint256 proposalId) external whenNotPaused {
        require(proposalId < s_proposals.length, "Proposal does not exist");
        require(!s_hasVoted[msg.sender][proposalId], "Already voted");
        require(block.timestamp <= s_proposals[proposalId].endTime, "Voting period has ended");
        require(!s_proposals[proposalId].executed, "Proposal already executed");

        s_hasVoted[msg.sender][proposalId] = true;
        s_proposals[proposalId].voteCount++;

        emit Voted(msg.sender, proposalId);
    }

    /**
     * @dev 执行投票通过的提案
     * @param proposalId 提案的ID
     */
    function executeProposal(uint256 proposalId) external onlyOwner whenNotPaused {
        require(proposalId < s_proposals.length, "Proposal does not exist");
        require(!s_proposals[proposalId].executed, "Proposal already executed");
        require(block.timestamp > s_proposals[proposalId].endTime, "Voting period not ended");

        s_proposals[proposalId].executed = true;
        
        emit ProposalExecuted(proposalId);
    }

    /**
     * @dev 暂停合约
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev 恢复合约
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev 获取提案详情
     * @param proposalId 提案的ID
     */
    function getProposal(uint256 proposalId) external view returns (Proposal memory) {
        require(proposalId < s_proposals.length, "Proposal does not exist");
        return s_proposals[proposalId];
    }

    /**
     * @dev 获取提案数量
     */
    function getProposalCount() external view returns (uint256) {
        return s_proposals.length;
    }

    /**
     * @dev 检查用户是否已对特定提案投票
     * @param user 用户地址
     * @param proposalId 提案ID
     */
    function hasVoted(address user, uint256 proposalId) external view returns (bool) {
        return s_hasVoted[user][proposalId];
    }

    /**
     * @dev 获取当前合约版本
     */
    function getVersion() external view returns (uint256) {
        return s_version;
    }

    /**
     * @dev UUPS升级授权，只有所有者可以升级合约
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
} 