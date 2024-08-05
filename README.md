

# MERKLE AIRDROPsh

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Forge](https://img.shields.io/badge/forge-v0.2.0-blue.svg?style=for-the-badge)
![Solc](https://img.shields.io/badge/solc-v0.8.20-blue.svg?style=for-the-badge)
[![GitHub License](https://img.shields.io/github/license/trashpirate/merkle-airdrop?style=for-the-badge)](https://github.com/trashpirate/merkle-airdrop/blob/master/LICENSE)

[![Website: nadinaoates.com](https://img.shields.io/badge/Portfolio-00e0a7?style=for-the-badge&logo=Website)](https://nadinaoates.com)
[![LinkedIn: nadinaoates](https://img.shields.io/badge/LinkedIn-0a66c2?style=for-the-badge&logo=LinkedIn&logoColor=f5f5f5)](https://linkedin.com/in/nadinaoates)
[![Twitter: N0_crypto](https://img.shields.io/badge/@N0_crypto-black?style=for-the-badge&logo=X)](https://twitter.com/N0_crypto)


## About
This repo contains an airdrop contract based on merkle proofs. It is part of the [Updraft](https://updraft.cyfrin.io/) tutorial about merkle proofs and signatures.

## Tutorial Notes  
These are notes from the tuturial about signatures and transaction types:

### Signatures
To get signer from encrypted message you need the encrypted message and signature (v, r, and s). Then compared if retrieved signer is the right one. The signature can be concatenated (bytes) or in three components v,r,s (uint8, bytes32, bytes32). The Openzeppelin cryptography library should be use to avoid replay attacks.

#### Signature Standards

**EIP-191:**  
EIP-191 defines how a signature is structured:  
0x19 - version (0x00 - address of intended validator, 0x01 - EIP712, 0x45) - version specific data - message to sign

**EIP-712:**  
EIP-712 structures version specific data:

- domain separator (version specific data): = hashstruct that defines the structure of the message being signed
- domain:
	struct eip712Domain = {
		string name
		string version
		uint256 chainId
		address verifyingContract
		bytes32 salt
	}
- hashStruct: hash of the type of the Hash hashed together with the hash of the struct data
- type of the hash: hashed type declaration of the struct

#### ECDSA Signatures 
- Secp256k1 curve, symmetrical about x axis
- r: x point on curve
- s: proof signer knows private key
- v: if in positive or negative part of curve

- private key (p): random  number between 0 and n-1 (n: order)
- public key: = p * (generator point)

**Sign message:**   
1. Calculating the message hash, using a cryptographic hash function e.g. SHA-256 `h = hash(msg)`
2. Generating securely a random number `k`
3. Calculating the random point `R = k * G` and take its x-coordinate: `r = x_R`
4. Calculating the signature proof s using the formula: `s = k^-1 * (h + p * r) mod n` (where p is the signer’s private key, and the order n)
5. Return the signature `(r, s)`.

**Signiture verification:**   
1. Calculating the message hash, with the same hash function used when signing
2. Calculating the modular inverse s1 of the signature proof: `s1 = s^-1 (mod n)`
3. Recovering the random point used during the signing: `R' = (h * s1) * G + (r * s1) * pubKey`
4. Retrieving r' from R': `r' = R'.x`
5. Calculating the signature validation result by comparing whether `r' == r`

https://www.cyfrin.io/blog/elliptic-curve-digital-signature-algorithm-and-signatures

### Transaction Types:

1. 0x00 Legacy: Transaction before the introduction of transaction types
2. 0x01 Optional Access Lists (EIP-2930): contains additional access list parameters to restrict transactions between contracts to specific contract addresses and reduces gas savings
3. 0x02 EIP-1559: Addresses high network fees and congestion by replacing the gas price with a base fee and max gas parameters:
    - max priority fee per gas
    - max fee per gas ( = max priority fee per gas + base fee )
    ZkSync does support 0x2 but does not do anything with the max gas parameters
4. 0x03 Blob Transactions (EIP-4844): initial scaling solution for rollups with parameters:
    - max blob fee per gas
    - blob versioned hashes (list of the version blob hashes)
    Blob fee is non-refundable (burned)

**ZkSync specific transaction types:**  
- 0x71 Type 113 for structured data (EIP-712): account abstraction, has fields:
    - gas per published data to L1
    - custom signature
    - pay master parameters (who is paying for fee)
- 0xff Priority transactions: transactios from L1 to L2


## Installation

### Install dependencies
```bash
$ make install
```

## Usage
Before running any commands, create a .env file and add the following environment variables:
```bash
# network configs
RPC_LOCALHOST="http://127.0.0.1:8545"

# ethereum nework
RPC_ETH_SEPOLIA=<rpc url>
RPC_ETH_MAIN=<rpc url>
ETHERSCAN_KEY=<api key>

```

### Run tests
```bash
$ forge test
```

### Run local testnet (anvil)
```bash
$ anvil
```

### Deploy contract on local testnet
```bash
$ make deploy-local
```

### Sign a message
1. Copy-paste contract address of airdrop contract in Makefile to set variable `CONTRACT_ADDRESS`
2. Run following command with preferred account:
    ```bash
    $ make sign-message
    ```
3. To verify the signature without the contract run:
    ```bash
    $ make verify-signature
    ```

### Claim airdrop:
To claim an airdrop with an address run the `Interact.s.sol` script using the command:
 ```bash
$ make claim-local
```

*View Makefile for additional interactions with the airdrop and token contract.*

## Author

👤 **Nadina Oates**

* Website: [nadinaoates.com](https://nadinaoates.com)
* Twitter: [@N0\_crypto](https://twitter.com/N0\_crypto)
* Github: [@trashpirate](https://github.com/trashpirate)
* LinkedIn: [@nadinaoates](https://linkedin.com/in/nadinaoates)


## 📝 License

Copyright © 2024 [Nadina Oates](https://github.com/trashpirate).

This project is [MIT](https://github.com/trashpirate/merkle-airdrop/blob/master/LICENSE) licensed.


