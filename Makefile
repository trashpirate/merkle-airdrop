
-include .env

.PHONY: all test clean deploy

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:; forge install foundry-rs/forge-std --no-commit && forge install Cyfrin/foundry-devops --no-commit && forge install OpenZeppelin/openzeppelin-contracts --no-commit && forge install https://github.com/dmfxyz/murky.git --no-commit

# update dependencies
update:; forge update

# compile
build:; forge build

# test
test :; forge test 

# test coverage
coverage:; @forge coverage --contracts src
coverage-report:; @forge coverage --contracts src --report debug > coverage.txt

# take snapshot
snapshot :; forge snapshot

# format
format :; forge fmt

# spin up local test network
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# spin up fork
fork :; @anvil --fork-url ${RPC_ETH_MAIN} --fork-block-number 19799039 --fork-chain-id 1 --chain-id 123

# security
slither :; slither ./src 

# local deployment
deploy-local: 
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url ${RPC_LOCALHOST} --private-key ${DEFAULT_ANVIL_KEY} --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast 

deploy-local-token: 
	@forge script script/DeployERC20Token.s.sol:DeployERC20Token --rpc-url ${RPC_LOCALHOST} --private-key ${DEFAULT_ANVIL_KEY} --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast 

# testnet deployment
deploy-testnet-token: 
	@forge script script/DeployERC20Token.s.sol:DeployERC20Token --rpc-url $(RPC_ETH_SEPOLIA) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

deploy-testnet: 
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(RPC_ETH_SEPOLIA) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

# mainnet deployment
deploy-mainnet: 
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(RPC_ETH_MAIN) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast -g 110 --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

# hash message
CONTRACT_ADDRESS := 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
sign-message:
	@hash=$$(cast call ${CONTRACT_ADDRESS} "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://127.0.0.1:8545); \
	echo MessageHash: $$hash; \
	cast wallet sign --no-hash $$hash --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
	
verify-signature:
	@hash=$$(cast call ${CONTRACT_ADDRESS} "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://127.0.0.1:8545); \
	echo MessageHash: $$hash; \
	signature=$$(cast wallet sign --no-hash $$hash --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80); \
	echo Signature: $$signature; \
	valid=$$(cast call ${CONTRACT_ADDRESS} "isValidSignature(address,bytes32,bytes)(bool)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 $$hash $$signature); \
	echo Valid: $$valid

# claim airdrop
claim-local:
	@forge script script/Interact.s.sol:ClaimAirdrop --rpc-url ${RPC_LOCALHOST} --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast

-include ${FCT_PLUGIN_PATH}/makefile-external