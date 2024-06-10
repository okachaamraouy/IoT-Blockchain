# Introduction

This post will discuss building a private network of multiple nodes based on Geth (the official Go implementation of the Ethereum protocol).

If the nodes of an Ethereum network are not connected to the main network or any other public network, then the network is called a private network.

We must provide our private network with a network ID not used by public networks. You can check all the public network ids at chainlist.

Sometimes network id is also referred to as chain id. Let’s move ahead and set up the private blockchain network.

# Setup

Step 1: Install the geth client

The first thing we need to do is to download and install the Geth client. You should have access to geth binary before moving ahead.

apt-get install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum  
