// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VotingSystem.sol";

/**
 * @title VotingSystemV2
 * @dev VotingSystem合约的升级版本，增加了新的功能
 * @notice 这个合约增加了取消提案和加权投票的功能
 */
contract VotingSystemV2 is VotingSystem {
    // 存储新增的投票权重
    mapping(address => uint256) private s_voterWeight;
    
    // 最小权重值
    uint256 private constant MIN_WEIGHT = 1;
    
    // 新增事件
    event ProposalCancelled(uint256 indexed proposalId);
    event VoterWeightSet(address indexed voter, uint256 weight);

    /**
     * @dev 在升级后被调用以初始化新的存储变量
     * @notice 这是v2版本的初始化函数，升级后调用
     */
    function initializeV2() external reinitializer(2) {
        s_version = 2;
    }

    /**
     * @dev 根据投票者的权重进行投票
     * @param proposalId 提案的ID
     */
    function weightedVote(uint256 proposalId) external whenNotPaused {
        require(proposalId < s_proposals.length, "Proposal does not exist");
        require(!s_hasVoted[msg.sender][proposalId], "Already voted");
        require(block.timestamp <= s_proposals[proposalId].endTime, "Voting period has ended");
        require(!s_proposals[proposalId].executed, "Proposal already executed");
        
        uint256 weight = s_voterWeight[msg.sender];
        if (weight == 0) {
            weight = MIN_WEIGHT; // 如果没有设置权重，使用最小权重
        }
        
        s_hasVoted[msg.sender][proposalId] = true;
        s_proposals[proposalId].voteCount += weight;
        
        emit Voted(msg.sender, proposalId);
    }
    
    /**
     * @dev 设置投票者的权重
     * @param voter 投票者地址
     * @param weight 权重值
     */
    function setVoterWeight(address voter, uint256 weight) external onlyOwner {
        require(weight >= MIN_WEIGHT, "Weight must be at least MIN_WEIGHT");
        s_voterWeight[voter] = weight;
        
        emit VoterWeightSet(voter, weight);
    }
    
    /**
     * @dev 取消一个未执行的提案
     * @param proposalId 提案的ID
     */
    function cancelProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < s_proposals.length, "Proposal does not exist");
        require(!s_proposals[proposalId].executed, "Proposal already executed");
        
        delete s_proposals[proposalId];
        
        emit ProposalCancelled(proposalId);
    }
    
    /**
     * @dev 获取投票者的权重
     * @param voter 投票者地址
     */
    function getVoterWeight(address voter) external view returns (uint256) {
        uint256 weight = s_voterWeight[voter];
        return weight == 0 ? MIN_WEIGHT : weight;
    }
} 