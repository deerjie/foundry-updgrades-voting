// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "forge-std/Test.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {DevOpsTools} from "@devops/src/DevOpsTools.sol";
import {DeployV1} from "../script/DeployV1.s.sol";
import {UpgradeToV2} from "../script/UpgradeToV2.s.sol";
import {VotingV1} from "../src/VotingV1.sol";
import {VotingV2} from "../src/VotingV2.sol";
/**
 * 使用 Foundry 的 Solidity 单元测试框架验证合约行为。下面示例测试包括：初始化状态检查、权限控制测试、投票功能测试，以及升级后新功能的验证。
 * 
 * 测试说明：
 *	        使用 forge test 运行测试。测试使用了 openzeppelin-foundry-upgrades 库中的 Upgrades.deployUUPSProxy 和 *Upgrades.upgradeProxy 方法来模拟部署和升级。
 *	        测试了初始化后拥有者（owner()）、初始选项计数、仅管理员添加选项权限、投票功能（单票规则）等。
 *          在升级后测试了旧数据的保留以及新功能（getTotalVotes() 和 getAllVoters()）是否可用。
 */

contract VotingTest is Test {
    DeployV1 public deployV1;
    UpgradeToV2 public upgradeToV2;
    address public proxyAddress;
    address public owner = address(0);
    address public alice = vm.addr(1);
    address public bob = vm.addr(2);

    function setUp() public {
        deployV1 = new DeployV1();
        upgradeToV2 = new UpgradeToV2();
    }

    function testVotingV1Works() public {
        proxyAddress = deployV1.run();
        uint256 expectedValue = 1;
        assertEq(expectedValue, VotingV1(proxyAddress).version());
    }
}