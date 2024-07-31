## MerkleAirdrop


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


Get signer:

message, v, r, s
bytes32(message) -> why is this equal to keccak256(string) ???


To get signer from encrypted message you need the encrypted message and signature (v, r, and s)

Then compared if retrieved signer is the right one.


EIP-191

0x19 - version (0x00 - address of intended validator, 0x01 - EIP712, 0x45) - version specific data - message to sign

EIP-712 structures version specific data

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


## ECDSA Signatures

- Secp256k1 curve, symmetrical about x axis
- r: x point on curve
- s: proof signer knows private key
- v: if in positive or negative part of curve


- private key (p): random  number between 0 and n-1 (n: order)
- public key: = p * (generator point)


- sign message:  
	1. Calculating the message hash, using a cryptographic hash function e.g. SHA-256 `h = hash(msg)`
	2. Generating securely a random number `k`
	3. Calculating the random point `R = k * G` and take its x-coordinate: `r = x_R`
	4. Calculating the signature proof s using the formula: `s = k^-1 * (h + p * r) mod n` (where p is the signer’s private key, and the order n)
	5. Return the signature `(r, s)`.

- signiture verification:  
    1. Calculating the message hash, with the same hash function used when signing
    2. Calculating the modular inverse s1 of the signature proof: `s1 = s^-1 (mod n)`
    3. Recovering the random point used during the signing: `R' = (h * s1) * G + (r * s1) * pubKey`
    4. Retrieving r' from R': `r' = R'.x`
    5. Calculating the signature validation result by comparing whether `r' == r`

https://www.cyfrin.io/blog/elliptic-curve-digital-signature-algorithm-and-signatures

## Transaction Types:

1. 0x00 Legacy: Transaction before the introduction of transaction types
2. 0x01 Optional Access Lists (EIP-2930): contains additional access list parameters to restrict transactions between contracts to specific contract addresses and reduces gas savings
3. 0x02 EIP-1559: Addresses high network fees and congestion by replacing the gas price with a base fee and max gas paramters:
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