-include .env

.PHONY: all deploy-anvil

all: deploy-anvil

deploy-anvil :; @forge script script/Atomic.s.sol:DeployAtomic --rpc-url http://localhost:8545  --broadcast

deploy :; @forge script script/Atomic.s.sol:DeployAtomic --rpc-url ${CHAIN_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv
