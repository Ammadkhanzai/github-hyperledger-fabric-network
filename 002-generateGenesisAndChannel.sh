#!/bin/sh

# export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/bin:${PWD}:$PATH
# export FABRIC_CFG_PATH=${PWD}
# export PATH=${PWD}/bin:$PATH
# export FABRIC_CFG_PATH=${PWD}
# export VERBOSE=false

export CHANNEL_NAME=vrschannel
export SYS_CHANNEL_NAME=vrssyschannel

mkdir generatedConfig 2>/dev/null
rm generatedConfig/genesis.block generatedConfig/channel.tx 2>/dev/null

# generate genesis block for orderer
configtxgen -profile Genesis -outputBlock generatedConfig/genesis.block -channelID $SYS_CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi




# generate channel transaction
configtxgen -profile Channel -outputCreateChannelTx generatedConfig/channel_$CHANNEL_NAME.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi


# generate ANCHOR PEER transaction for ExciseORG
configtxgen -profile Channel -outputAnchorPeersUpdate generatedConfig/ExciseMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ExciseMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update configuration transaction..."
  exit 1
fi

# generate ANCHOR PEER transaction for ManufacturerORG
configtxgen -profile Channel -outputAnchorPeersUpdate generatedConfig/ManufacturerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ManufacturerMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update configuration transaction..."
  exit 1
fi

# generate ANCHOR PEER transaction for DealerORG
configtxgen -profile Channel -outputAnchorPeersUpdate generatedConfig/DealerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DealerMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update configuration transaction..."
  exit 1
fi

