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

The most important thing here is chainId inside config. It is the network id we discussed in the previous section. 
This genesis file defines the initial configuration and state of an Ethereum blockchain network. Below is a detailed description of its components:

Genesis File Description

config:

chainId: 1412, a unique identifier for the blockchain network.
homesteadBlock, eip150Block, eip150Hash, eip155Block, eip158Block, byzantiumBlock, constantinopleBlock, petersburgBlock, istanbulBlock, berlinBlock, londonBlock: All set to 0, indicating these Ethereum improvement proposals (EIPs) and hard forks are enabled from the genesis block.
ethash: The mining algorithm used for proof-of-work (PoW).
nonce: "0x0", a 64-bit value used to demonstrate proof-of-work in block mining.

timestamp: "0x64184068", the Unix timestamp for the genesis block creation.

extraData: "0x0000000000000000000000000000000000000000000000000000000000000000", optional data that can be included by the miner.

difficulty: "2000", the initial difficulty level for mining.

gasLimit: "3000000", the maximum amount of gas allowed per block.

mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000", a hash used in the mining process.

coinbase: "0x0000000000000000000000000000000000000000", the address that receives the mining rewards.

alloc: Pre-allocated balances for specific accounts:

Several accounts with addresses "0000000000000000000000000000000000000000" to "00000000000000000000000000000000000000fd" each have a balance of "0x1".
Account "9B79560F0A82AF0A51A29467Cf9B1180C856CEb1" has a balance of "0x700000000000000000000000000000000000000000000000000000000000000".
Account "49B75bc4b99Ff359b30f58D882fa4b738d4a5b70" has a balance of "0x800000000000000000000000000000000000000000000000000000000000000".
Account "97C638FD33644FAF0502a76F303c0B0522e52fa3" has a balance of "0x900000000000000000000000000000000000000000000000000000000000000".

The bellow Figure depicts the balance of the account 2 on the Metamask wallet:

![Screenshot from 2024-04-24 18-36-22](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/3663c74f-d3fb-43f6-9d5f-6219039b13e2)


number: "0x0", the block number of the genesis block.

gasUsed: "0x0", the total gas used by transactions in this block.

parentHash: "0x0000000000000000000000000000000000000000000000000000000000000000", the hash of the parent block (none for the genesis block).

baseFeePerGas: null, indicating no base fee is set (relevant for EIP-1559, not applicable here).

# Step 3: Initiate the private blockchain

We have the configuration ready for the genesis block. Let’s run our first geth command to initialize the private blockchain.

```log
geth init --datadir ./node1 genesis.json
```
This command will create a folder node1 in the current directory. Inside this directory, there will be a lot of folders/files created. You are not required to know them all.

Optionally, you can run the command below to access the Javascript console attached to the blockchain we created.

```log
geth --datadir ./node1 console
```

Make sure you disconnect from the console by typing exit. You can also use Ctrl+d to stop.

# Step 4: Add the first node to the private blockchain

To start the first private node on the blockchain network and also attach a console to it, run the below command:

```log
geth --datadir Node1 --networkid 1412 --http --http.port "8545" --http.addr "localhost" --port "30310" --http.corsdomain "*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --allow-insecure-unlock --unlock 0 --password password.txt --http.vhosts "*" --mine --miner.etherbase 0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70 --miner.threads 10 --nodiscover console
```

This command initializes and starts a Geth (Go Ethereum) node with specific parameters. Below is a detailed discussion of each part of the command:

Command Breakdown
geth: This is the command to run the Geth client.

* `--datadir Node1:` Specifies the data directory for the node, named Node1.

* `--networkid 1412:` Sets the network ID to 1412, ensuring the node connects to the specified Ethereum network.

* `--http:` Enables the HTTP-RPC server.

* `--http.port "8545":` Sets the HTTP-RPC server port to 8545.

* `--http.addr "localhost":` Binds the HTTP-RPC server to localhost.

* `--port "30310":` Sets the port for P2P communication to 30310.

* `--http.corsdomain "*":` Allows access to the HTTP-RPC server from any domain. This is useful for development but should be restricted in production environments for security reasons.

* `--http.api "admin,eth,debug,miner,net,txpool,personal,web3":` Specifies the APIs available over the HTTP interface, including:

* `admin:` Node administration.

* `eth:` Ethereum blockchain.

* `debug:` Debugging functions.

* `miner:` Mining operations.

* `net:` Network information.

* `txpool:` Transaction pool.

* `personal:` Account management.

* `web3:` Web3.js utility functions.


* `--allow-insecure-unlock:` Allows insecure account unlocking via the RPC interface. This should be used with caution and ideally avoided in production.

* `--unlock 0:` Unlocks the first account (index 0) specified in the node’s keystore.

* `--password password.txt:` Uses the password file password.txt to unlock the account.

* `--http.vhosts "*":` Allows access to the HTTP-RPC server from any virtual host. Again, this is useful for development but should be restricted in production.

* `--mine:` Starts the node in mining mode, meaning it will attempt to validate transactions and create new blocks.

* `--miner.etherbase 0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70:` Sets the etherbase (the account that receives mining rewards) to 0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70.

* `--miner.threads 10:` Allocates 10 CPU threads for mining operations.

* `--nodiscover:` Disables the node discovery mechanism, which means the node will not connect to other peers automatically. This is useful for private networks or isolated development environments.

* `console:` Opens the Geth interactive JavaScript console, allowing the user to interact with the node directly.

Discussion

This command is designed to set up a Geth node with specific configurations aimed at running a private Ethereum network. The key points to note include:

Network Isolation: By setting a custom networkid, the node will only connect to other nodes with the same network ID, ensuring it operates on a private network.

HTTP-RPC Server: Enabling the HTTP-RPC server and exposing various APIs allows for interaction with the node via HTTP requests. This is useful for remote management and integration with other tools, but it also poses security risks if not properly secured.

Mining Configuration: The node is configured to mine blocks using 10 CPU threads, with rewards directed to a specified etherbase account. This makes the node actively participate in the network by validating transactions and creating new blocks.

Account Management: The command unlocks an account using a password file, facilitating automated transactions and mining rewards collection.

Security Considerations: Several options (--allow-insecure-unlock, --http.corsdomain "*", --http.vhosts "*") are set to permissive values, which are suitable for a controlled development environment but should be restricted in production to prevent unauthorized access and potential attacks.

No Peer Discovery: By disabling peer discovery, the node will not attempt to find and connect to other nodes automatically. This can be useful for a controlled test environment but would need to be adjusted for a fully operational network where peer connections are necessary.

Overall, this command is tailored for a development or testing environment, providing flexibility and ease of use, but it would require tightening of security settings for deployment in a production environment.

The command output should have a enode value. This value represents the node. See the below snippet for example.

![Screenshot from 2024-04-24 17-42-41](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/3ba11a96-fb0d-49a2-a6c2-da65cbf45ca9)

# Step 5: Add one more node to the private blockchain

We need a separate folder/directory for the datadir in the second node, but the genesis file will be the same. So let’s first initialize the second node. Use the below command for that:

```blog
geth --datadir ./node2 init genesis.json
```
To run the node, we need to change a few input parameters as discussed in the previous step. I have listed an example command below:

```blog
geth --datadir Node2 --networkid 1412 --http.addr "localhost" --port "30311" --authrpc.port "4546" --http.corsdomain "*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --allow-insecure-unlock --unlock 0 --password password.txt --http.vhosts "*" --mine --miner.etherbase 0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70 --miner.threads 10 --nodiscover console
```

Take note of the enode value for this node also.

```blog
enode: ''enode://2901e179d1a5c2d38b9e648406869ce5579012c04e834b8ec29103ace310964978b6dc66cfa1331f15e8af2c34a53a1756e2d0215b6800dc5300e3072be80528@192.168.100.11:30311?discport=0''
```

We can repeat this process for any number of nodes as required.

# Step 6: Connect node2 with node1 as peer

For this post, we will add the peer nodes using a manual process. There are ways to automatic discovery of peers. We will cover that in the next post.

Go to the node1 console and add the node2 enode value using admin.addPeer command. The command will look like the below:

```blog
admin.addPeer(''enode://2901e179d1a5c2d38b9e648406869ce5579012c04e834b8ec29103ace310964978b6dc66cfa1331f15e8af2c34a53a1756e2d0215b6800dc5300e3072be80528@192.168.100.11:30311?discport=0'')
```

After running the command, Check if the peer is added successfully by running the command admin.peers. 

You can also run the admin.peers in the node2 console to see the enode for node1.

There are different ways to create an account, but we will use the simplest one here. Run personal.newAccount() command on the console of both nodes and remember the Passphrase entered. 

The command will return an address. It is the public address of your newly created account. Also, it will return the path of the private secret key file corresponding to this address. These two values combined are called public-private key pair.

See the list of accounts and their balance using below commands:

```blog
# It will return list of accounts
eth.accounts
...

#The first account is accounts[0], use that to get its balance
eth.getBalance(eth.accounts[0])
```

To fund the account, let’s start mining!

Go to the node1 console and type the below command to start mining. The value passed in the start method is the number of CPUs used.

```blog
miner.start(1)
```

Mining can be stopped at any time by command: miner.stop()



