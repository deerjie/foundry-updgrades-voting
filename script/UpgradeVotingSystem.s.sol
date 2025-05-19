// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {VotingSystemV2} from "../src/VotingSystemV2.sol";
import {IERC1967} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Strings} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol";

/**
 * @title UpgradeVotingSystem
 * @dev 用于将VotingSystem合约升级到V2的脚本
 */
contract UpgradeVotingSystem is Script {
    using Strings for address;

    /**
     * @dev 运行升级脚本
     * @param proxyAddress 要升级的代理合约地址
     * @return newImplementation 新的实现合约地址
     */
    function run(address proxyAddress) external returns (address newImplementation) {
        vm.startBroadcast();

        // 1. 部署新的实现合约
        VotingSystemV2 votingSystemV2Implementation = new VotingSystemV2();
        newImplementation = address(votingSystemV2Implementation);
        console.log("Deployed VotingSystemV2 implementation at: ", newImplementation.toHexString());
        
        // 2. 获取代理合约实例
        VotingSystemV2 proxy = VotingSystemV2(proxyAddress);
        
        // 3. 执行升级
        proxy.upgradeToAndCall(
            newImplementation,
            abi.encodeWithSelector(VotingSystemV2.initializeV2.selector)
        );
        
        // 4. 验证升级成功
        console.log("Successfully upgraded proxy to VotingSystemV2");
        console.log("New version: ", proxy.getVersion());

        vm.stopBroadcast();
        return newImplementation;
    }
} 