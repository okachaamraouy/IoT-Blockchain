To create, test, deploy, and interact with smart contracts using Truffle and a private Ethereum blockchain set up with Geth, follow these detailed steps:

# Step 1: Set Up Your Private Ethereum Blockchain

1.1 Install Geth

First, install Geth by following the official installation guide.

1.2 Create the Genesis File

Create a genesis file (genesis.json) with the following content:

```blog
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

1.3 Initialize the Geth Node

Initialize the Geth node with the genesis file:

```blog
geth --datadir Node1 init genesis.json
```

1.4 Start the Geth Node

To start the first private node on the blockchain network and also attach a console to it, run the below command:

```blog
geth --datadir Node1 --networkid 1412 --http --http.port "8545" --http.addr "localhost" --port "30310" --http.corsdomain "*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --allow-insecure-unlock --unlock 0 --password password.txt --http.vhosts "*" --mine --miner.etherbase 0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70 --miner.threads 10 --nodiscover console
```

# Step 2: Set Up Truffle Project

2.1 Install Truffle

Install Truffle globally using npm:

```blog
npm install -g truffle
```

2.2 Create a New Truffle Project

Create a new Truffle project:

```blog
mkdir my-dapp
cd my-dapp
truffle init
```

# Step 3: Create a Smart Contract (e.g., Meteo station contract for the weather station data)

In the `contracts` directory, create a file Meteo_Station.sol:

```blog
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
 
contract Meteo_Station{

	struct data1 {
		string Timestamp;
		string time;
		string TempIn;
		string TempOut;
		string HumIn;
		string HumOut;
		string BarTrend;
		string WindSpeed;
		string WindDir;
		string RainDay;
	}

	struct data2 {
		string SolarRad;
		string UV;
		string RainRate;
		string SunRise;
		string SunSet;
		string Barometer;
		string EtDay;
	}

  	data1[] public weather_station_data1;
	data2[] public weather_station_data2;
		
	function add_Data1(string memory _Timestamp, string memory _time, string memory _TempIn, string memory _TempOut, string memory _HumIn, string memory _HumOut, string memory _BarTrend, string memory _WindSpeed, string memory _WindDir, string memory _RainDay) public {
		weather_station_data1.push(data1({Timestamp: _Timestamp, time: _time, TempIn: _TempIn, TempOut: _TempOut, HumIn: _HumIn, HumOut: _HumOut, BarTrend: _BarTrend, WindSpeed: _WindSpeed, WindDir: _WindDir, RainDay: _RainDay}));  
	}

	function add_Data2(string memory _SolarRad, string memory _UV, string memory _RainRate, string memory _SunRise, string memory _SunSet, string memory _Barometer, string memory _EtDay) public {
		weather_station_data2.push(data2({SolarRad: _SolarRad, UV: _UV, RainRate: _RainRate, SunRise: _SunRise, SunSet: _SunSet, Barometer: _Barometer, EtDay: _EtDay})); 
	}
	
	function Call_Data() public view returns (data1[] memory, data2[] memory) {
		return (weather_station_data1, weather_station_data2);
	} 

}
```
# Step 4: Compile the Smart Contract

Compile the contract using Truffle:

```blog
truffle compile
```

# Step 5: Configure Truffle for Deployment

5.1 Update truffle-config.js

Configure truffle-config.js to connect to your private Ethereum network:

```blog
/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * https://trufflesuite.com/docs/truffle/reference/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

require('dotenv').config();
// const mnemonic = process.env["MNEMONIC"];
// const infuraProjectId = process.env["INFURA_PROJECT_ID"];
//const fs = require("fs");

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache, geth, or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
     development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: 1412,       // Any network (default: none)
     },
    //
    //goerli: {
     // //provider: () => new HDWalletProvider(mnemonic, `https://goerli.infura.io/v3/${infuraProjectId}`),
    //  provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://eth-goerli.g.alchemy.com/v2/${process.env.API_KEY}`),
    //  network_id: 5,       // Goerli's id
    //  chain_id: 5,
    //  gasLimit: 3141592,
    //  gasPrice:0
    //}
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.13",      // Fetch exact version from solc-bin
    }
  }
};
```

5.2 Create Migration Script

In the migrations directory, create a file 1_deploy_contracts.js:

```blog
var Meteo_Station = artifacts.require("./Meteo_Station.sol");
module.exports = function(deployer) {
  deployer.deploy(Meteo_Station);
};
```

Step 6: Deploy the Smart Contract

Deploy the contract to your private Ethereum network:

```blog
truffle migrate --network development
```
After executing the above command, you will see a screen similar to the one shown below.

![Screenshot from 2024-04-24 18-45-38](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/9b735053-8b09-4167-b7a9-e335db121869)


Step 7: Interact with the Deployed Contract Using Python

First, you will need to install the Web3.py library using pip:

```blog
pip install web3
```

Create a Python file interact_private_blockchain.py to interact with the deployed contract:

```blog
from solcx import compile_standard, install_solc
import json   #to save the output in a JSON file
with open("Meteo_Station.sol", "r") as file:
    contact_list_file = file.read()

install_solc("0.8.13")
# Compiling Solidity Code: It compiles the Solidity code using compile_standard function from solcx, specifying the Solidity version and settings for output selection such as ABI and bytecode.
compiled_sol = compile_standard( 
    {
        "language": "Solidity",
        "sources": {"Meteo_Station.sol": {"content": contact_list_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"] # output needed to interact with and deploy contract 
                }
            }
        },
    },
    solc_version = '0.8.13',
)
print(compiled_sol)
# The compiled output including ABI and bytecode is saved into a JSON file named compiled_code.json.
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)    

# get bytecode
bytecode = compiled_sol["contracts"]["Meteo_Station.sol"]["Meteo_Station"]["evm"]["bytecode"]["object"]

# get ABI
abi = json.loads(compiled_sol["contracts"]["Meteo_Station.sol"]["Meteo_Station"]["metadata"])["output"]["abi"]

from web3 import Web3

# Connecting to Ethereum Node: It connects to a local Ethereum node running on http://127.0.0.1:8545 using Web3.
# For connecting to private Blockchain
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
# chain_id = 1
address = "0x49B75bc4b99Ff359b30f58D882fa4b738d4a5b70"
private_key = "0x68cb87d0c8e98561b4477ee61ecb54e477da010721b4657f831bcc53aa0a79bf" # leaving the private key like this is very insecure if you are working on real world project# Create the contract in Python
# Contract Deployment: It creates a contract object using the bytecode and ABI, and deploys it to the blockchain using the specified address and private key.
Meteo_Station = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get the number of latest transaction
nonce = w3.eth.get_transaction_count(address)

# Create a contract instance
contact_list = w3.eth.contract(address="0x0455d9Fd03FF82a4082a3AccB6De452c0E166537", abi=abi)
# Interacting with Contract: It interacts with the deployed contract by calling a function (add_Data1) with some parameters, signing the transaction with the private key, and sending it to the blockchain.
store_contact1 = contact_list.functions.add_Data1(
    "data1", "data2","data3","data4","data5","data6","data7","data8","data9","data10"
).build_transaction({
    "chainId": 1412,
    "from": address,
    "gasPrice": w3.eth.gas_price,
    "nonce": nonce
})

# Interacting with Contract: It interacts with the deployed contract by calling a function (add_Data2) with some parameters, signing the transaction with the private key, and sending it to the blockchain.
store_contact2 = contact_list.functions.add_Data2(
    "data11", "data12","data13","data14","data15","data16","data17","data18","data19","data20"
).build_transaction({
    "chainId": 1412,
    "from": address,
    "gasPrice": w3.eth.gas_price,
    "nonce": nonce + 1
})


# Sign the transaction
sign_store_contact1 = w3.eth.account.sign_transaction(
    store_contact1, private_key=private_key
)
# add_Data2
sign_store_contact2 = w3.eth.account.sign_transaction(
    store_contact2, private_key=private_key
)
# Send the transaction
send_store_contact1 = w3.eth.send_raw_transaction(sign_store_contact1.rawTransaction)

send_store_contact2 = w3.eth.send_raw_transaction(sign_store_contact2.rawTransaction)

# Transaction Receipt: It waits for the transaction to be mined and retrieves the transaction receipt.
transaction_receipt1 = w3.eth.wait_for_transaction_receipt(send_store_contact1)

transaction_receipt2 = w3.eth.wait_for_transaction_receipt(send_store_contact2)

print("transaction_receipt1:", transaction_receipt1)
print("transaction_receipt2:", transaction_receipt2)

try:
    # Call contract function
    data = contact_list.functions.Call_Data().call()
    print("Data read from the smart contract:", data)
except Exception as e:
    print("Error calling contract function:", e)
```

Run the interaction script using Python:
```blog
python interact_private_blockchain.py
```

After executing the above command, you will see a screen similar to the one shown below.


![Screenshot from 2024-04-24 19-18-25](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/7f31ff9e-fc3c-4bf1-b92d-cddfb5a5a598)

