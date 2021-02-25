//Import Hyperledger Fabric 1.4 programming model - fabric-network
'use strict';
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { Gateway, Wallets } = require('fabric-network');

const { buildCCP, buildWallet } = require('./app/AppUtil');

const express = require('express')
const app = express()






async function contractEvents() {

  try {
    const orgName = 'excise.vrs.com';
    const ccpName = 'connection-profile-excise.json';
    const connectionProfile = buildCCP( orgName , ccpName );

    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(__dirname, 'wallet-excise');
    const wallet = await buildWallet(Wallets, walletPath);


    //connect to Fabric Network, but starting a new gateway
    let identity = await wallet.get('admin');
    
    const gateway = new Gateway();
    

    //use our config file, our peerIdentity, and our discovery options to connect to Fabric network.
    await gateway.connect(connectionProfile, {
      wallet,
      identity: 'admin',
      discovery: { enabled: true , asLocalhost: true },
    });
    // console.log('gateway connect');

    //connect to our channel that has been created on IBM Blockchain Platform
    const network = await gateway.getNetwork('vrschannel');

    //connect to our insurance contract that has been installed / instantiated on IBM Blockchain Platform
    const contract = await network.getContract('vrschaincode');

  

    // let n = await gateway.getNetwork("vrschannel");
    // let contract = n.getContract("vrschaincode");
    // contract.addContractListener(async (event) => {
    //   console.log(event.eventName, event.payload.toString("utf-8"));
      
    // });

     contract.addContractListener(async  (event) => {
      if(event.eventName == "VehicalCreated"){
        console.log('');
        console.log('************************ Start Trade Event *******************************************************');
        console.log('                        New Vehical Created.                  ');
        let transactionEvent = event.getTransactionEvent();
        console.log("Transaction ID: "+transactionEvent.transactionId);
        console.log("Transaction Status: "+transactionEvent.status);
        let payload = JSON.parse(event.payload.toString("utf-8"));
        console.log("-------------------------vehical details------------------------------------");  
        console.log('Engine Number: '+ payload.engineNumber );
        console.log('Chassis Number: '+ payload.chassisNumber );
        console.log('Manufacturer Name: '+ payload.manufacturerName );
        if(payload.state == "UNDER_MANUFACTURER"){
          var date = new Date(payload.manufactureDate * 1000);
          console.log('date: '+ date.toLocaleDateString() +" "+ date.toLocaleTimeString("en-US"));
        }
        console.log('************************ End Trade Event ************************************');
        
      }
      if(event.eventName == "VehicalDeleted"){
        console.log('');
        console.log('************************ Start Trade Event *******************************************************');
        console.log('                        Vehical Deleted                   ');
        let transactionEvent = event.getTransactionEvent();
        console.log("Transaction ID: "+transactionEvent.transactionId);
        console.log("Transaction Status: "+transactionEvent.status);
        let payload = JSON.parse(event.payload.toString("utf-8"));
        console.log("-------------------------vehical details------------------------------------");  
        console.log('Engine Number: '+ payload.engineNumber );
        console.log('Chassis Number: '+ payload.chassisNumber );
        // console.log('Manufacturer Name: '+ payload.manufacturerName );
        console.log('************************ End Trade Event ************************************');
        
      }
      if(event.eventName == "VehicalTransfered"){
        console.log('');
        console.log('************************ Start Trade Event *******************************************************');
        console.log('                        Vehical Transfered                    ');
        let transactionEvent = event.getTransactionEvent();
        console.log("Transaction ID: "+transactionEvent.transactionId);
        console.log("Transaction Status: "+transactionEvent.status);
        let payload = JSON.parse(event.payload.toString("utf-8"));
        console.log("-------------------------vehical details------------------------------------");  
        console.log('Engine Number: '+ payload.engineNumber );
        console.log('Chassis Number: '+ payload.chassisNumber );
        console.log('************************ End Trade Event ************************************');
        
      }
      if(event.eventName == "VehicalReceived"){
        console.log('');
        console.log('************************ Start Trade Event *******************************************************');
        console.log('                        Vehical Received                    ');
        let transactionEvent = event.getTransactionEvent();
        console.log("Transaction ID: "+transactionEvent.transactionId);
        console.log("Transaction Status: "+transactionEvent.status);
        let payload = JSON.parse(event.payload.toString("utf-8"));
        console.log("-------------------------vehical details------------------------------------");  
        console.log('Engine Number: '+ payload.engineNumber );
        console.log('Chassis Number: '+ payload.chassisNumber );
        if(payload.state == "UNDER_CUSTOMER" && payload.clientIdentity != "null" ){
          console.log('Owner Name: '+ payload.ownerName );
          console.log('Number Plate: '+ payload.numberplate );
          var date = new Date(payload.registrationDate * 1000);
          console.log('date: '+ date.toLocaleDateString() +" "+ date.toLocaleTimeString("en-US"));
        }
        console.log('************************ End Trade Event ************************************');
        
      }






      //  let after= event.getTransactionEvent();
      //  console.log(event);
      //  console.log(event.getTransactionEvent());
      //  console.log(after.getBlockEvent());
      // let abc = event.payload.toString("utf-8");

      //convert event to something we can parse 
      // event = err.payload.toString("utf-8");
      // // event = JSON.parse(err)
      // console.log("------------------------");
      // //where we output the TradeEvent
      // console.log('************************ Start Trade Event *******************************************************');
      // console.log(abc);
      
      // console.log('************************ End Trade Event ************************************');
    });


    // Disconnect from the gateway.
    await gateway.disconnect();

  } catch (error) {
    console.error(`Failed to submit transaction: ${error}`);
  }
}

contractEvents();

const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})