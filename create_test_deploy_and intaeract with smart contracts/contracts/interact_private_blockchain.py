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
