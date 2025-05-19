// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

/**
基础版本合约 VotingV1.sol 允许管理员（合约拥有者）创建投票选项，用户对选项投票。合约采用无构造函数模式，使用 initialize() 方法进行初始化 ￼；并继承 OpenZeppelin 的 OwnableUpgradeable（权限管理）和 UUPSUpgradeable（实现 UUPS 升级逻辑）。在 initialize 中需调用 __Ownable_init() 和 __UUPSUpgradeable_init() 完成父合约初始化。实现要点包括：仅管理员可添加选项、每个地址只能投票一次、选项计票等。
 */
/// @title VotingV1 - 基础投票合约（UUPS 可升级）
/// @dev 支持管理员添加选项、用户投票
contract VotingV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// 投票选项结构体
    struct Option {
        string name;
        uint256 voteCount;
    }

    Option[] public options;               // 选项列表
    mapping(address => bool) public hasVoted; // 记录每个地址是否已投票

    /// 事件：添加选项
    event OptionAdded(uint indexed optionId, string optionName);
    /// 事件：投票
    event Voted(address indexed voter, uint indexed optionId);

    /// @dev 初始化函数（代替构造函数），只可调用一次
    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    /// @dev 管理员添加新的投票选项
    function addOption(string memory name) external onlyOwner {
        options.push(Option({ name: name, voteCount: 0 }));
        emit OptionAdded(options.length - 1, name);
    }

    /// @dev 用户对指定选项投票（每个地址仅能投票一次）
    function vote(uint256 optionIndex) public virtual{
        require(!hasVoted[msg.sender], "Already voted");
        require(optionIndex < options.length, "Invalid option");
        hasVoted[msg.sender] = true;
        options[optionIndex].voteCount += 1;
        emit Voted(msg.sender, optionIndex);
    }

    /// @dev 返回选项总数
    function getOptionCount() external view returns (uint256) {
        return options.length;
    }

    /// @dev 返回指定选项的名称和票数
    function getOption(uint256 optionIndex) external view returns (string memory, uint256) {
        require(optionIndex < options.length, "Invalid option");
        Option storage opt = options[optionIndex];
        return (opt.name, opt.voteCount);
    }

    /// @dev UUPS 升级授权：仅合约拥有者可升级合约 [oai_citation:3‡docs.openzeppelin.com](https://docs.openzeppelin.com/contracts/4.x/api/proxy#:~:text=UUPS%20proxies%20are%20implemented%20using,into%20a%20UUPS%20compliant%20implementation)
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function version() public pure returns (uint256) {
        return 1;
    }
}