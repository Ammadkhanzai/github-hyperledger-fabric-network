#!/bin/bash

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false
export SYS_CHANNEL=vrssyschannel

docker-compose -f docker-compose.yaml down
docker-compose -f docker-compose.yaml up -d


# discover --configFile conf.yaml --peerTLSCA ./crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt --userKey ./crypto-config/peerOrganizations/manufacturer.vrs.com/tlsca/priv_sk --userCert ./crypto-config/peerOrganizations/manufacturer.vrs.com/users/User1@manufacturer.vrs.com/msp/signcerts/User1@manufacturer.vrs.com-cert.pem  --MSP ManufacturerMSP saveConfig


# discover --peerTLSCA ./crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt --userKey ./crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/msp/keystore/priv_sk --userCert ./crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/msp/signcerts/Admin@manufacturer.vrs.com-cert.pem --MSP ManufacturerMSP --tlsCert ./crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.crt --tlsKey ./crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/tls/client.key peers --server localhost:9051

# discover --configFile conf.yaml --peerTLSCA ./crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/tls/ca.crt --userKey ./crypto-config/peerOrganizations/manufacturer.vrs.com/peers/peer0.manufacturer.vrs.com/msp/keystore/priv_sk --userCert ./crypto-config/peerOrganizations/manufacturer.vrs.com/users/Admin@manufacturer.vrs.com/msp/signcerts/Admin@manufacturer.vrs.com-cert.pem --MSP ManufacturerMSP  saveConfig


# discover --configFile conf.yaml peers --channel vrschannel  --server localhost:9051





# discover --configFile conf.yaml 
# --peerTLSCA ./artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt 
# --userKey ./artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/keystore/priv_sk 
# --userCert ./artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/signcerts/peer0.org1.example.com-cert.pem --MSP Org1MSP 
# --tlsCert ./artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/tls/client.crt 
# --tlsKey ./artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/tls/client.key 
# saveConfig

