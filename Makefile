-include .env
devops :; forge install Cyfrin/foundry-devops;

build :; forge build;

test :; forge test;

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing

NETWORK_ARGS := --rpc-url 127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployVotingSystem.s.sol:DeployVotingSystem $(NETWORK_ARGS)

upgrade:
	@forge script script/UpgradeVotingSystem.s.sol:UpgradeVotingSystem --sig "run(address)" $(PROXY) $(NETWORK_ARGS)