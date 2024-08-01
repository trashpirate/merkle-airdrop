// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    /**
     * TYPES
     */
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * STORAGE VARIABLES
     */
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address user => bool claimed) private s_hasClaimed;

    /**
     * EVENTS
     */
    event ClaimedAirdrop(address account, uint256 amount);

    /**
     * ERRRORS
     */
    error MerkleAirdrop__HasAlreadyClaimed();
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__InvalidSignature();

    constructor(bytes32 merkleRoot, address airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = IERC20(airdropToken);
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__HasAlreadyClaimed();
        }
        // check the signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        // hasing twice helps to prevent collisions (second pre-image attacks)
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true;
        emit ClaimedAirdrop(account, amount);

        // transfer tokens
        i_airdropToken.safeTransfer(account, amount);
    }

    // external functions

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (address) {
        return address(i_airdropToken);
    }

    // public functions
    function getMessageHash(address account, uint256 amount) public view returns (bytes32 digest) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    // private/internal functions
    function isValidSignature(address account, bytes32 digest, bytes calldata signature) public pure returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(digest, signature);
        return actualSigner == account;
    }

    // private/internal functions
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
