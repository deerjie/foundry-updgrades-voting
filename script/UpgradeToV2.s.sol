// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../src/VotingV2.sol";
/**
 * 1. 将已部署的代理合约升级到 VotingV2，实现新功能。需要将之前的代理地址作为输入。
 * 2. 执行命令：
 *      export VOTING_PROXY_ADDRESS=0xYourProxyAddress
 *      forge script script/UpgradeV2.s.sol --broadcast --skip-simulation
 */
contract UpgradeToV2 is Script {
    function run(address VOTING_PROXY_ADDRESS) external returns(address proxyAddress){
        vm.startBroadcast();
        address proxyAddress = vm.envAddress(VOTING_PROXY_ADDRESS); 
        // 升级代理到 VotingV2，调用 initializeV2 进行初始化（此例为空）
        Upgrades.upgradeProxy(
            proxyAddress,
            "VotingV2.sol",
            abi.encodeCall(VotingV2.initializeV2, ())
        );
        console.log("Voting contract upgraded to V2 at proxy", proxyAddress);
        vm.stopBroadcast();
    }
}