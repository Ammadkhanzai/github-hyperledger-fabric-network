#!/bin/sh

# export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/bin:${PWD}:$PATH
# export FABRIC_CFG_PATH=${PWD}
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/
export VERBOSE=false

# chmod +x file name

# remove previous crypto material and config transactions
rm -fr crypto-config/*

cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

