// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {MerkleAirdrop} from "./../src/MerkleAirdrop.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";
import {HelperConfig} from "./../script/HelperConfig.s.sol";
import {DeployMerkleAirdrop} from "./../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    // config
    DeployMerkleAirdrop deployment;
    HelperConfig config;

    // contracts
    ERC20Token token;
    MerkleAirdrop airdrop;

    // helpers
    bytes32 root;
    uint256 public AMOUNT = 25 * 1e18;
    bytes32[] public PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576),
        bytes32(0xc2ef27e475b955c035da5b0bb2847aaadfab48761646acc36250572a3d56cbd3)
    ];
    address user;
    uint256 userPrivKey;

    function setUp() public {
        deployment = new DeployMerkleAirdrop();
        (airdrop, config) = deployment.run();

        (address airdropToken,) = config.activeNetworkConfig();

        token = ERC20Token(airdropToken);

        token.mint(address(airdrop), AMOUNT * 6);
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, AMOUNT, PROOF);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
