

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/orderer.vrs.com/orderers/orderer.vrs.com/msp/tlscacerts/tlsca.orderer.vrs.com-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/excise.vrs.com/peers/peer0.excise.vrs.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/dealer.vrs.com/peers/peer0.dealer.vrs.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/generatedConfig/
export CHANNEL_NAME=vrschannel






setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/ordererOrganizations/orderer.vrs.com/orderers/orderer.vrs.com/msp/tlscacerts/tlsca.orderer.vrs.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/ordererOrganizations/orderer.vrs.com/users/Admin@orderer.vrs.com/msp

}




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


CHANNEL_NAME="vrschannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode-javascript/"
CC_NAME="vrschaincode"

packageChaincode() {
    # rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ./generatedConfig/${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ./generatedConfig/${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    # setGlobalsForPeer1Org1
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    # echo "===================== Chaincode is installed on peer1.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ./generatedConfig/${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

    # setGlobalsForPeer1Org2
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    # echo "===================== Chaincode is installed on peer1.org2 ===================== "

    setGlobalsForPeer0Org3
    peer lifecycle chaincode install ./generatedConfig/${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org3 ===================== "

}


queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}


approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vrs.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --waitForEvent \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

getBlock() {
    setGlobalsForPeer0Org1
    peer channel getinfo  -c mychannel -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vrs.com --tls \
        --cafile $ORDERER_CA
}
checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --sequence ${VERSION} --output json 
    echo "===================== checking commit readyness from org 1 ===================== "
}


approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vrs.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --package-id ${PACKAGE_ID} \
        --waitForEvent \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadyness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json 
    echo "===================== checking commit readyness from org 1 ===================== "
}


approveForMyOrg3() {
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vrs.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --waitForEvent \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --version ${VERSION} --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadyness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json 
    echo "===================== checking commit readyness from org 1 ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.vrs.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_ORG3_CA \
        --waitForEvent \
        --signature-policy "OR ('ExciseMSP.peer','ManufacturerMSP.peer','DealerMSP.peer')" \
        --version ${VERSION} --sequence ${VERSION} 

}

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvoke() {
    

    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vrs.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_ORG3_CA \
        -c '{"function": "CreateVehical","Args":["98","bogus23","2020","Ravi","7hdf7K"]}'

}

chaincodeQuery() {
    setGlobalsForPeer0Org2

    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetAllAssets","Args":[]}'
    
}

packageChaincode
sleep 5
installChaincode
sleep 5
queryInstalled
sleep 5
approveForMyOrg1
sleep 5
checkCommitReadyness
sleep 5
approveForMyOrg2
sleep 5
checkCommitReadyness
sleep 5
approveForMyOrg3
sleep 5
checkCommitReadyness
sleep 5
commitChaincodeDefination
sleep 5

queryCommitted
sleep 5
# chaincodeInvoke
# sleep 5
# chaincodeQuery