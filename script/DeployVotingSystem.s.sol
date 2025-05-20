// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {Strings} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Strings.sol";

/**
 * @title DeployVotingSystem
 * @dev 用于部署VotingSystem升级合约的脚本
 */
contract DeployVotingSystem is Script {
    using Strings for address;

    /**
     * @dev 运行部署脚本
     * @return proxy 代理合约地址
     * @return implementation 实现合约地址
     */
    function run() external returns (address proxy, address implementation) {
        vm.startBroadcast();

        // 1. 部署实现合约
        VotingSystem votingSystemImplementation = new VotingSystem();
        implementation = address(votingSystemImplementation);
        
        // 2. 生成初始化数据
        address owner;
        if (block.chainid == 11155111) { // Sepolia测试网
            // 使用环境变量中的OWNER_ADDRESS
            owner = vm.envAddress("OWNER_ADDRESS");
            console.log("Sepolia network detected. Using OWNER_ADDRESS from .env:", owner);
        } else {
            // 使用部署者地址
            owner = msg.sender;
            console.log("Using deployer as owner:", owner);
        }

        bytes memory initializeData = abi.encodeWithSelector(
            VotingSystem.initialize.selector,
            owner // 使用确定的所有者地址
        );
        
        // 3. 部署代理并指向实现合约
        ERC1967Proxy proxy_ = new ERC1967Proxy(
            implementation,
            initializeData
        );
        proxy = address(proxy_);
        
        // 4. 输出部署信息
        console.log("Deployed VotingSystem proxy at: ", proxy.toHexString());
        console.log("Implementation address: ", implementation.toHexString());

        vm.stopBroadcast();
        return (proxy, implementation);
    }
} 