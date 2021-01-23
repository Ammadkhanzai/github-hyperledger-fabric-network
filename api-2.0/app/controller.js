'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const bodyParser = require('body-parser');
const util = require('util');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil');
const { buildCCP, buildWallet } = require('./AppUtil');
let mspID;

logger.level = 'debug';

exports.RegisterUser = async (userID,organizationName) => {

    const orgName = organizationName.toLowerCase()+'.vrs.com';
    const ccpName = 'connection-profile-'+organizationName.toLowerCase()+'.json';
    const caName = 'ca.'+organizationName.toLowerCase()+'.vrs.com';
    const ccp = buildCCP( orgName , ccpName );
    const caClient = buildCAClient(FabricCAServices, ccp, caName );
    const walletPath = path.join(__dirname, 'wallet-'+organizationName.toLowerCase());
    const wallet = await buildWallet(Wallets, walletPath);

    if(organizationName.toLowerCase() == "manufacturer"){
        mspID = "ManufacturerMSP";
    }else if(organizationName.toLowerCase() == "dealer"){
        mspID = "DealerMSP";
    }else if(organizationName.toLowerCase() == "excise"){
        mspID = "ExciseMSP";
    }else{
        throw new Error(`no such MSP found: ${organizationName.toLowerCase()}`);
    }

    await enrollAdmin(caClient, wallet, mspID);
    await registerAndEnrollUser(caClient, wallet, mspID , userID);

    var response = {
        success: true,
        message: userID + ' enrolled Successfully',
    };
    return response;

}

exports.isUserRegistered = async  (userID, organizationName) => {

    const walletPath = path.join(__dirname, 'wallet-'+organizationName.toLowerCase());
    const wallet = await buildWallet(Wallets, walletPath);

    const userIdentity = await wallet.get(userID);
    if (userIdentity) {
        console.log(`An identity for the user ${userID} exists in the wallet`);
        return true;
    }
    return false;
}

exports.invokeTransaction = async (channelName, chaincodeName, fcn, args, userID, organizationName ) => {
    try {
        logger.debug(util.format('\n============ invoke transaction on channel %s ============\n', channelName));

        const orgName = organizationName.toLowerCase()+'.vrs.com';
        const ccpName = 'connection-profile-'+organizationName.toLowerCase()+'.json';
        const ccp = buildCCP( orgName , ccpName );

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(__dirname, 'wallet-'+organizationName.toLowerCase());
        const wallet = await buildWallet(Wallets, walletPath);

        // Check to see if we've already enrolled the user.
        let identity = await wallet.get(userID);
        if (!identity) {
            console.log(`An identity for the user ${userID} does not exist in the wallet`);
            throw new Error(`No such Identity found in Wallet : ${userID.toLowerCase()}`);
        }
        const connectOptions = {
            wallet,
            identity: userID, 
            discovery: { enabled: true , asLocalhost: true },
        }
        const gateway = new Gateway();

        try{

            await gateway.connect(ccp, connectOptions);
            
            const network = await gateway.getNetwork(channelName);
            const contract = network.getContract(chaincodeName);

            let result
            let message;
            if (fcn === "CreateVehical") {
                result = await contract.submitTransaction(fcn, args[0], args[1], args[2], args[3], args[4], args[5]);
                message = `Successfully added the vehical asset with key ${args[0]}`;
            }
            if(fcn === "DeleteVehical"){
                result = await contract.submitTransaction(fcn, args[0]);
                message = `Successfully deleted the vehical asset with key ${args[0]}`;
            }
            if(fcn === "ReadAsset"){
                result = await contract.evaluateTransaction(fcn, args[0]);
                message = `Successfully Get the vehical asset with key ${args[0]}`;
            }
            if(fcn === "TransferToDealer"){
                result = await contract.submitTransaction(fcn, args[0],args[1]);
                message = `Successfully transfer the vehical asset from Manufacturer to Dealer with key ${args[0]}`;
            }
            if(fcn === "ReceiveFromManufacturer"){
                result = await contract.submitTransaction(fcn, args[0]);
                message = `Successfully receive the vehical asset from Manufacturer to Dealer with key ${args[0]}`;
            }
            if(fcn === "TransferToOwner"){
                result = await contract.submitTransaction(fcn, args[0], args[1], args[2], args[3], args[4], args[5]);
                message = `Successfully transfer the vehical asset from Dealer to Owner with key ${args[0]}`;
            }
            if(fcn === "ReceiveFromDealer"){
                result = await contract.submitTransaction(fcn, args[0]);
                message = `Successfully receive the vehical asset from Dealer to Owner with key ${args[0]}`;
            }
            if(fcn === "ChangeOwner"){
                result = await contract.submitTransaction(fcn, args[0], args[1], args[2], args[3], args[4] );
                message = `Successfully transfer the vehical asset from Previous Owner to New Owner with key ${args[0]}`;
            }
            if(fcn === "ReceiveFromOwner"){
                result = await contract.submitTransaction(fcn, args[0]);
                message = `Successfully receive the vehical asset from Previous Owner to New Owner with key ${args[0]}`;
            }
            if(fcn === "QueryAssetsByOwner"){
                result = await contract.evaluateTransaction(fcn, args[0]);
                message = `Query Asset by engine number : ${args[0]}`;
            }
            if(fcn === "GetAssetHistory"){
                result = await contract.evaluateTransaction(fcn, args[0]);
                message = `Get VehicalAsset History by ID : ${args[0]}`;
            }
            if(fcn === "AssetExists"){
                result = await contract.evaluateTransaction(fcn, args[0]);
                message = `Check If Asset exist with the ID : ${args[0]}`;
            }
            if(fcn === "GetAllAssets"){
                result = await contract.evaluateTransaction(fcn);
                message = `Get All the Vehical Asset exist`;
            }

            result = JSON.parse(result.toString());
            let response = {
                message: message,
                result
            }
            return response;

        }finally {
			gateway.disconnect();
		}    
    } catch (error) {

        console.log(`Getting error: ${error}`)
        return error.message

    }
}