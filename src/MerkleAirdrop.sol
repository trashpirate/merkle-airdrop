// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title MerkleAirdrop
/// @author Nadina Oates
/// @notice Contract implementing a claiming contract using merkle proofs
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

    /// @notice Constructor
    /// @param merkleRoot Merkel root of the merkle tree
    /// @param airdropToken Token address of token to be claimed
    /// @dev inherits from Openzeppelin EIP712
    constructor(bytes32 merkleRoot, address airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = IERC20(airdropToken);
    }

    /// @notice Claims airdrop tokens
    /// @param account Address to receive airdrop
    /// @param amount Amount to be claimed
    /// @param merkleProof Merkle Proof associated with account
    /// @param signature associated with account
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

    /**
     * EXTERNAL FUNCTIONS
     */

    /// @notice Gets merkle root
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /// @notice Gets airdrop token address
    function getAirdropToken() external view returns (address) {
        return address(i_airdropToken);
    }

    /**
     * PUBLIC FUNCTIONS
     */
    /// @notice Gets message hash for the airdrop
    /// @param account Adress receiving the airdrop
    /// @param amount Airdrop amount
    function getMessageHash(address account, uint256 amount) public view returns (bytes32 digest) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /// @notice Checks if signature is valid (for convenience, not use in contract)
    /// @param account Adress receiving the airdrop
    /// @param digest Message hash
    /// @param signature Account's signature
    function isValidSignature(address account, bytes32 digest, bytes calldata signature) public pure returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(digest, signature);
        return actualSigner == account;
    }

    /**
     * PRIVATE/INTERNAL
     */

    /// @notice Checks if signature is valid
    /// @param account Adress receiving the airdrop
    /// @param digest Message hash
    /// @param v polarity
    /// @param r x point on elliptic curve
    /// @param s proof signer knows private key
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
