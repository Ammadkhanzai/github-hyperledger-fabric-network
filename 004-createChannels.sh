
#peer channel create -o orderer.vrs.com:7050 -c mynetwork -f ./channel-artifacts/channel.tx --outputBlock ./generatedConfig/vrschannel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/vrs.com/orderers/orderer.vrs.com/msp/tlscacerts/tlsca.vrs.com-cert.pem
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false


docker exec -it cli.excise bash
export CHANNEL_NAME=vrschannel

peer channel create -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./channel_$CHANNEL_NAME.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE

# peer channel create -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel_$CHANNEL_NAME.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
#peer 0 envirmental variable already set in cli
peer channel join -b $CHANNEL_NAME.block
export CORE_PEER_ADDRESS=peer1.excise.vrs.com:8051
peer channel join -b $CHANNEL_NAME.block

peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
# peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE

#--------------------------------------------------------------------------#

docker exec -it cli.manufacturer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false

peer channel fetch 0 $CHANNEL_NAME.block -o orderer.vrs.com:7050 -c $CHANNEL_NAME --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
#peer 0 envirmental variable already set in cli
peer channel join -b $CHANNEL_NAME.block
export CORE_PEER_ADDRESS=peer1.manufacturer.vrs.com:10051
peer channel join -b $CHANNEL_NAME.block

peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
# peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE

#--------------------------------------------------------------------------#

docker exec -it cli.dealer bash
export CHANNEL_NAME=vrschannel
export FABRIC_CFG_PATH=$PWD
export VERBOSE=false


peer channel fetch 0 $CHANNEL_NAME.block -o orderer.vrs.com:7050 -c $CHANNEL_NAME --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
#peer 0 envirmental variable already set in cli
peer channel join -b $CHANNEL_NAME.block
export CORE_PEER_ADDRESS=peer1.dealer.vrs.com:12051
peer channel join -b $CHANNEL_NAME.block

peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE
# peer channel update -o orderer.vrs.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $TLS_ORDERER_CA --clientauth --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE