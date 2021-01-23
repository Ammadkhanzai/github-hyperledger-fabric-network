export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false


CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode"
CC_NAME="vrschaincodejavascript"

docker exec -it cli.excise bash
export CHANNEL_NAME=vrschannel

peer lifecycle chaincode package vrschaincodejavascript.tar.gz --path /opt/gopath/src/github.com/chaincode --lang node --label vrschaincodejavascript_1


peer lifecycle chaincode install vrschaincodejavascript.tar.gz --peerAddresses $CORE_PEER_ADDRESS -o orderer.vrs.com:7050  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/connection-profile-excise.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE 

exit
docker exec -it cli.manufacturer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode install vrschaincodejavascript.tar.gz --peerAddresses $CORE_PEER_ADDRESS -o orderer.vrs.com:7050  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/connection-profile-manufacturer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE

exit
docker exec -it cli.dealer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode install vrschaincodejavascript.tar.gz --peerAddresses $CORE_PEER_ADDRESS -o orderer.vrs.com:7050  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/connection-profile-dealer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE

# exit

peer lifecycle chaincode queryinstalled --peerAddresses $CORE_PEER_ADDRESS -o orderer.vrs.com:7050  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/connection-profile-dealer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --output json


"package_id": "vrschaincodejavascript_1:4e051d0da9ffd35244a2af43039de552797fb6d5ec04c084829675fa1ef85326",
"label": "vrschaincodejavascript_1"

exit 

docker exec -it cli.excise bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode approveformyorg  -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/connection-profile-excise.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1  --package-id vrschaincodejavascript_1:4e051d0da9ffd35244a2af43039de552797fb6d5ec04c084829675fa1ef85326 --sequence 1 --waitForEvent --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')"

peer lifecycle chaincode queryapproved -o orderer.vrs.com:7050 --channelID $CHANNEL_NAME --name vrschaincode --sequence 1 --output json

peer lifecycle chaincode checkcommitreadiness -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/connection-profile-excise.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1 --sequence 1 --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" --output json

exit

docker exec -it cli.manufacturer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode approveformyorg  -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/connection-profile-manufacturer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1  --package-id vrschaincodejavascript_1:4e051d0da9ffd35244a2af43039de552797fb6d5ec04c084829675fa1ef85326 --sequence 1 --waitForEvent --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')"

peer lifecycle chaincode queryapproved -o orderer.vrs.com:7050 --channelID $CHANNEL_NAME --name vrschaincode --sequence 1 --output json

peer lifecycle chaincode checkcommitreadiness -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/connection-profile-manufacturer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1 --sequence 1 --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" --output json

exit
docker exec -it cli.dealer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode approveformyorg  -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/connection-profile-dealer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1  --package-id vrschaincodejavascript_1:4e051d0da9ffd35244a2af43039de552797fb6d5ec04c084829675fa1ef85326 --sequence 1 --waitForEvent --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')"

peer lifecycle chaincode queryapproved -o orderer.vrs.com:7050 --channelID $CHANNEL_NAME --name vrschaincode --sequence 1 --output json

peer lifecycle chaincode checkcommitreadiness -o orderer.vrs.com:7050 --peerAddresses $CORE_PEER_ADDRESS  --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/connection-profile-dealer.yaml  --tls true --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --cafile $TLS_ORDERER_CA --certfile $CORE_PEER_TLS_CLIENTCERT_FILE --clientauth true --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --channelID $CHANNEL_NAME --name vrschaincode --version 1 --sequence 1 --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" --output json

exit

docker exec -it cli.excise bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer lifecycle chaincode commit -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --version 1 --sequence 1 --waitForEvent --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" --peerAddresses peer0.excise.vrs.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.key --peerAddresses peer0.manufacturer.vrs.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.key --peerAddresses peer0.dealer.vrs.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/peers/peer0.dealer.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/tls/client.key

# --connectionProfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/connection-profile.yaml

peer lifecycle chaincode querycommitted -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.excise.vrs.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.key --output json


peer lifecycle chaincode querycommitted -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.manufacturer.vrs.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.key --output json

peer lifecycle chaincode querycommitted -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.dealer.vrs.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/peers/peer0.dealer.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/tls/client.key --output json



peer chaincode invoke -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.excise.vrs.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.key -c '{"function":"CreateVehical","Args":["98","bogus23","2020","Ravi","7hdf7K"]}'


peer chaincode query -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.excise.vrs.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.key -c '{"function":"CreateVehical","Args":["98","bogus23","2020","Ravi","7hdf7K"]}'

peer chaincode query -o orderer.vrs.com:7050 --clientauth true --tls true --cafile $TLS_ORDERER_CA --channelID $CHANNEL_NAME --name vrschaincode --peerAddresses peer0.excise.vrs.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt --certfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.crt --keyfile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/tls/client.key -c '{"function":"GetAllAssets","Args":[]}'



















