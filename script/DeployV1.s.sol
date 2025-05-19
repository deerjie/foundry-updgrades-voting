// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "forge-std/Script.sol";
import { Upgrades } from "@openzeppelin-foundry-upgrades/src/Upgrades.sol";
import "../src/VotingV1.sol";

/**
 * 1. 使用 Foundry 的脚本功能可以方便地部署和升级合约。这里我们使用 OpenZeppelin 的 Foundry 升级插件 openzeppelin-foundry-upgrades，并在脚本中调用其 Upgrades.deployUUPSProxy 和 Upgrades.upgradeProxy 方法.
 * 2. 执行命令：forge script script/DeployV1.s.sol --broadcast --skip-simulation
 */
contract DeployV1 is Script {
    function run() external returns(address proxy){
        vm.startBroadcast();
        // 部署 UUPS 代理，使用 VotingV1 的 initialize 进行初始化
        address proxy = Upgrades.deployUUPSProxy(
            "VotingV1.sol",
            abi.encodeCall(VotingV1.initialize, ())
        );
        console.log("VotingV1 Proxy deployed at", proxy);
        vm.stopBroadcast();
    }
}