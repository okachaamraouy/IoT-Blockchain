# Introduction

This post will discuss building a private network of multiple nodes based on [Geth] (https://geth.ethereum.org/) (the official Go implementation of the Ethereum protocol).
If the nodes of an Ethereum network are not connected to the main network or any other public network, then the network is called a private network.
We must provide our private network with a network ID (1412) not used by public networks. You can check all the public network IDs at [chainlist] (https://chainlist.org/).
Sometimes network ID is also referred to as chain ID. Let’s move ahead and set up the private blockchain network.

# Setup

Step 1: Install the geth client

The first thing we need to do is to download and install the Geth client. You should have access to geth binary before moving ahead.

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
