// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract HelperConfig is Script, ScriptHelper {
    struct Input {
        address user;
        uint256 amont;
    }

    struct MerkleLeaf {
        Input[] inputs;
        bytes32[] proof;
        bytes32 root;
        bytes32 leaf;
    }

    struct MerkleTree {
        MerkleLeaf[] leaves;
    }

    using stdJson for string;

    bytes32 constant ROOT = 0xb48345fa05085aab0d80f05676162b7be8b2b43425de4bdac18dc052947e8735;
    string private outputPath = "/script/target/output.json";

    // chain configurations
    NetworkConfig public activeNetworkConfig;

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    struct NetworkConfig {
        address airdropToken;
        bytes32 root;
    }

    constructor() {
        if (block.chainid == 1) {
            /**
             * ethereum
             */
            activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            /**
             * sepolia
             */
            activeNetworkConfig = getTestnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getTestnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({airdropToken: 0xBb4f69A0FCa3f63477B6B3b2A3E8491E5425A356, root: ROOT});
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({airdropToken: 0xBb4f69A0FCa3f63477B6B3b2A3E8491E5425A356, root: ROOT});
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        ERC20Token token = new ERC20Token();
        vm.stopBroadcast();

        return NetworkConfig({airdropToken: address(token), root: ROOT});
    }
}
