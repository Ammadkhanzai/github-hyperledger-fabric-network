

export CORE_PEER_TLS_ENABLED=true

export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/orderer.vrs.com/orderers/orderer.vrs.com/msp/tlscacerts/tlsca.orderer.vrs.com-cert.pem

export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/dealer.vrs.com/peers/peer0.dealer.vrs.com/tls/ca.crt

export FABRIC_CFG_PATH=${PWD}/generatedConfig/

export CHANNEL_NAME=vrschannel


setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="ExciseMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1(){
    export CORE_PEER_LOCALMSPID="ExciseMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/excise.vrs.com/users/Admin@excise.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="ManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1Org2(){
    export CORE_PEER_LOCALMSPID="ManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="DealerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

setGlobalsForPeer1Org3(){
    export CORE_PEER_LOCALMSPID="DealerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/dealer.vrs.com/users/Admin@dealer.vrs.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
    
}



createChannel(){
    
    setGlobalsForPeer0Org1
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.vrs.com \
    -f ./generatedConfig/channel_${CHANNEL_NAME}.tx --outputBlock ./generatedConfig/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# removeOldCrypto(){
#     rm -rf ./api-1.4/crypto/*
#     rm -rf ./api-1.4/fabric-client-kv-org1/*
#     rm -rf ./api-2.0/org1-wallet/*
#     rm -rf ./api-2.0/org2-wallet/*
# }


joinChannel(){
    setGlobalsForPeer0Org1
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org1
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Org2
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org2
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block

    setGlobalsForPeer0Org3
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org3
    peer channel join -b ./generatedConfig/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Org1
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.vrs.com -c $CHANNEL_NAME -f ./generatedConfig/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Org2
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.vrs.com -c $CHANNEL_NAME -f ./generatedConfig/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Org3
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.vrs.com -c $CHANNEL_NAME -f ./generatedConfig/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

# removeOldCrypto

createChannel
sleep 5
joinChannel
sleep 5
updateAnchorPeers




