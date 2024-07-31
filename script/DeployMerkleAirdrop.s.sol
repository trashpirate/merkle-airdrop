// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "./../src/MerkleAirdrop.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMerkleAirdrop is Script {
    function run() external returns (MerkleAirdrop, HelperConfig) {
        HelperConfig config = new HelperConfig();

        (address airdropToken, bytes32 root) = config.activeNetworkConfig();

        vm.startBroadcast();
        MerkleAirdrop airdrop = new MerkleAirdrop(root, airdropToken);
        vm.stopBroadcast();
        return (airdrop, config);
    }
}
