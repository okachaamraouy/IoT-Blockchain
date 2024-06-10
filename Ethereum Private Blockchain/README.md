# Introduction

This post will discuss building a private network of multiple nodes based on [Geth](https://geth.ethereum.org/) (the official Go implementation of the Ethereum protocol).
If the nodes of an Ethereum network are not connected to the main network or any other public network, then the network is called a private network.
We must provide our private network with a network ID (1412) not used by public networks. You can check all the public network IDs at [ChainList](https://chainlist.org/).

Sometimes network ID is also referred to as chain ID. Let’s move ahead and set up the private blockchain network.

# Setup

Step 1: Install the geth client

The first thing we need to do is to download and install the Geth client. You should have access to Geth binary before moving ahead.

```log
apt-get install software-properties-common
```

```log
sudo add-apt-repository -y ppa:ethereum/ethereum
```

```log
sudo apt-get update
```

```log
sudo apt-get install ethereum
```

# Step 2: Create genesis.json

Every blockchain starts with a genesis (first) block. The genesis block is configured using a genesis.json file for a private network. Inside a new folder/directory, create a genesis.json file with the below content.

```log
{
    "config": {
      "chainId": 1412,	
      "homesteadBlock": 0,
      "eip150Block": 0,
      "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "eip155Block": 0,
      "eip158Block": 0,
      "byzantiumBlock": 0,
      "constantinopleBlock": 0,
      "petersburgBlock": 0,
      "istanbulBlock": 0,
      "berlinBlock": 0,
      "londonBlock": 0,
      "ethash": {}
    },
    "nonce": "0x0",
    "timestamp": "0x64184068",
    "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "difficulty": "2000",
    "gasLimit": "3000000",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {
      "0000000000000000000000000000000000000000": {
        "balance": "0x1"
      },
      "0000000000000000000000000000000000000001": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000f8": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000f9": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000fa": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000fb": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000fc": {
        "balance": "0x1"
      },
      "00000000000000000000000000000000000000fd": {
        "balance": "0x1"
      },
      "9B79560F0A82AF0A51A29467Cf9B1180C856CEb1": {
        "balance": "0x700000000000000000000000000000000000000000000000000000000000000"
      },
      "49B75bc4b99Ff359b30f58D882fa4b738d4a5b70": {
        "balance": "0x800000000000000000000000000000000000000000000000000000000000000"
      },
      "97C638FD33644FAF0502a76F303c0B0522e52fa3": {
        "balance": "0x900000000000000000000000000000000000000000000000000000000000000"
      }
    },
    "number": "0x0",
    "gasUsed": "0x0",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "baseFeePerGas": null
}
```
