// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {VotingV1} from "./VotingV1.sol";  // 继承基础版本

/**
 * 升级版本 VotingV2.sol 在 VotingV1 基础上新增投票统计功能。我们继承 VotingV1 合约，并在末尾添加新的存储变量和方法：记录所有参与投票的地址列表。具体新增功能包括返回投票总人数和所有投票人地址列表。为保证存储布局兼容，我们必须在父合约末尾添加新的状态变量
 * 说明： VotingV2 继承自 VotingV1，新增了 votersList 数组以保存每一个投票地址。重写的 vote 函数首先调用 super.vote(...) 执行原有逻辑，然后将投票人加入 votersList。新增的 getTotalVotes 和 getAllVoters 提供投票统计信息。注意，若有需要对新状态初始化，可在 initializeV2() 中通过 reinitializer(2) 标记二次初始化函数。
 */

/// @title VotingV2 - 升级后投票合约
contract VotingV2 is VotingV1 {
    // 新增：记录所有投票人的地址列表
    address[] private votersList;

    /// @dev UUPS 升级后可选的二次初始化函数（此例中无额外逻辑，可留空或执行其他操作）
    function initializeV2() public reinitializer(2) {
        // 扩展初始化（如设置新的状态变量）可以写在这里
    }

    /// @notice 重写投票函数，新增记录投票人列表
    function vote(uint256 optionIndex) public override {
        super.vote(optionIndex);  // 调用父合约逻辑（校验并计票）
        votersList.push(msg.sender);
    }

    /// @dev 获取总投票人数（即投票人列表长度）
    function getTotalVotes() external view returns (uint256) {
        return votersList.length;
    }

    /// @dev 获取所有投票人地址列表
    function getAllVoters() external view returns (address[] memory) {
        return votersList;
    }
    function version() public pure returns (uint256) {
        return 2;
    }
}