## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# 可升级智能合约示例项目

本项目是一个完整的可升级智能合约开发、部署和测试的示例，展示了如何使用OpenZeppelin的可升级合约框架和Foundry工具链创建一个安全且可扩展的投票系统。

## 项目背景

在区块链应用开发中，智能合约一旦部署就无法更改的特性既是优势也是挑战。随着业务发展，合约可能需要添加新功能、修复漏洞或优化性能。可升级合约为解决这个问题提供了一种方案，允许在保持状态数据和合约地址不变的情况下，更新合约逻辑。

本项目通过实现一个可升级的投票系统，展示了从设计、开发到测试的完整流程，帮助开发者理解和应用可升级合约的最佳实践。

## 项目概述

项目实现了一个简单的投票系统，该系统可以进行升级。通过这个项目，你可以学习：

1. 如何设计和实现可升级合约
2. 如何使用OpenZeppelin的可升级合约库
3. 如何使用Foundry进行合约部署和测试
4. 如何执行合约升级并验证其状态保持不变

## 技术栈与版本

### 主要组件

- **Solidity**: ^0.8.20
- **Foundry**: v1.1.0-stable
  - Forge: 用于测试和部署
  - Cast: 与EVM交互的命令行工具
  - Anvil: 本地以太坊节点
- **OpenZeppelin Contracts Upgradeable**: v5.3.0
- **OpenZeppelin Foundry Upgrades**: v0.4.0
- **Foundry DevOps**: 0.3.2
- **Forge Standard Library**: v1.9.7

### 代理模式

本项目使用UUPS（Universal Upgradeable Proxy Standard）模式实现可升级性，这是一种高效且灵活的可升级合约模式。

## 项目结构

- `src/`: 包含所有合约源代码
  - `VotingSystem.sol`: 初始的投票系统合约(V1)
  - `VotingSystemV2.sol`: 升级后的投票系统合约(V2)，增加了加权投票和取消提案功能
- `script/`: 包含部署和升级脚本
  - `DeployVotingSystem.s.sol`: 部署V1合约的脚本
  - `UpgradeVotingSystem.s.sol`: 将合约从V1升级到V2的脚本
- `test/`: 包含测试文件
  - `VotingSystemTest.t.sol`: 测试合约的部署、功能和升级
- `lib/`: 外部依赖库

## 合约逻辑详解

### VotingSystem (V1)

这是初始版本的投票系统合约，具有以下核心功能：

1. **提案管理**：
   - 创建提案：合约所有者可以创建新的投票提案
   - 提案状态：每个提案包含描述、投票数、执行状态和结束时间
   - 提案执行：投票期结束后，合约所有者可以执行提案

2. **投票机制**：
   - 基本投票：用户可以对未执行的活跃提案进行投票
   - 投票限制：每个用户对每个提案只能投票一次
   - 时间控制：只能在投票期内进行投票

3. **安全功能**：
   - 暂停机制：合约所有者可以在紧急情况下暂停合约
   - 权限控制：关键操作只能由合约所有者执行
   - 状态查询：提供各种视图函数查询合约状态

4. **可升级性**：
   - 使用UUPS模式实现可升级性
   - 合约所有者控制升级过程
   - 版本跟踪以便于管理

### VotingSystemV2 (V2)

V2版本在保持原有功能的基础上，增加了新的特性：

1. **加权投票系统**：
   - 用户可以拥有不同的投票权重
   - 合约所有者可以设置用户的权重
   - 没有设置权重的用户默认使用最小权重

2. **提案管理增强**：
   - 取消提案：合约所有者可以取消未执行的提案
   - 更灵活的投票机制

## 详细部署流程

### 环境准备

1. 安装Foundry工具链：
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. 克隆仓库并安装依赖：
   ```bash
   git clone <repository-url>
   cd foundry-upgrades-voting
   forge install
   ```

### 编译合约

```bash
forge build
```

这将编译所有合约并生成相应的ABI和字节码。

### 部署V1合约

部署初始版本的VotingSystem合约，包括以下步骤：

1. 部署实现合约
2. 部署代理合约并将其指向实现合约
3. 初始化合约状态

```bash
# 本地测试网络部署
forge script script/DeployVotingSystem.s.sol --rpc-url http://localhost:8545 --private-key <your_private_key> --broadcast

# 实际公共测试网络部署（例如Sepolia）
forge script script/DeployVotingSystem.s.sol --rpc-url <sepolia_rpc_url> --private-key <your_private_key> --broadcast --verify
```

### 与合约交互

部署后，你可以使用cast与合约进行交互：

```bash
# 创建提案
cast send <proxy_address> "createProposal(string,uint256)" "Test Proposal" 259200 --rpc-url <rpc_url> --private-key <your_private_key>

# 查询提案数量
cast call <proxy_address> "getProposalCount()" --rpc-url <rpc_url>

# 对提案进行投票
cast send <proxy_address> "vote(uint256)" 0 --rpc-url <rpc_url> --private-key <your_private_key>
```

### 升级到V2合约

当需要升级合约时，执行以下命令：

```bash
# 升级到V2合约
forge script script/UpgradeVotingSystem.s.sol --rpc-url <rpc_url> --private-key <your_private_key> --broadcast --sig "run(address)" <proxy_address>
```

升级过程包括：
1. 部署新的实现合约(VotingSystemV2)
2. 调用代理合约的升级函数
3. 初始化V2特定的存储变量

### 验证合约

如果在公共网络部署，可以验证合约：

```bash
forge verify-contract <implementation_address> src/VotingSystem.sol:VotingSystem --chain <chain_id> --api-key <etherscan_api_key>
forge verify-contract <proxy_address> lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy --chain <chain_id> --api-key <etherscan_api_key>
```

## 详细测试流程

项目包含全面的测试套件，涵盖合约部署、功能测试和升级过程。

### 运行所有测试

```bash
forge test -vv
```

### 测试特定功能

```bash
# 测试部署过程
forge test --match-test testDeployVotingSystem -vv

# 测试基本功能
forge test --match-test testVotingSystemFunctions -vv

# 测试升级过程
forge test --match-test testUpgradeToV2 -vv
```

### 测试覆盖的关键点

1. **部署测试**：
   - 验证代理和实现合约的正确部署
   - 验证合约初始化正确

2. **功能测试**：
   - 提案创建和查询
   - 投票机制
   - 重复投票保护
   - 暂停和恢复功能

3. **升级测试**：
   - 验证升级过程的正确执行
   - 确认原有数据在升级后保持不变
   - 测试新增功能（加权投票和提案取消）

4. **边界条件测试**：
   - 权限控制
   - 输入验证
   - 状态一致性

## 可升级合约设计考虑

1. **存储布局**: 在升级合约时保持存储布局不变，只添加新的状态变量
2. **初始化函数**: 使用初始化函数而不是构造函数
3. **访问控制**: 使用访问控制确保只有授权用户可以升级合约
4. **透明性**: 使用UUPS代理模式实现透明的可升级性
5. **重入保护**: 实现暂停机制，在紧急情况下保护合约

## 合约升级流程

1. 部署初始实现合约(VotingSystem)
2. 部署代理合约，指向初始实现
3. 通过代理与合约交互
4. 部署新的实现合约(VotingSystemV2)
5. 通过代理升级到新的实现
6. 调用新的初始化函数(initializeV2)设置新的状态变量

## 安全注意事项

- 确保在升级合约时不破坏存储布局
- 严格控制谁可以触发升级
- 在重要操作前进行充分测试
- 保护初始化函数不被重复调用
- 在生产部署前进行全面的安全审计

## 进阶使用

### Gas优化

运行gas报告以分析合约的gas使用情况：

```bash
forge test --gas-report
```

### Fork测试

在主网分叉上测试合约：

```bash
forge test --fork-url <mainnet_rpc_url>
```

### 自定义网络部署

在foundry.toml中配置自定义网络：

```toml
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
```

然后使用以下命令部署：

```bash
forge script script/DeployVotingSystem.s.sol --rpc-url sepolia --private-key <your_private_key> --broadcast
```

## 贡献指南

欢迎贡献代码和改进！请遵循以下步骤：

1. Fork仓库
2. 创建新分支进行修改
3. 提交PR并描述你的改动

## 许可证

MIT
