/*
 SPDX-License-Identifier: Apache-2.0
*/


'use strict';

const {Contract} = require('fabric-contract-api');

class Chaincode extends Contract {

	// CreateAsset - create a new asset, store into chaincode state
	async CreateVehical(ctx, assetID, engineNumber,chassisNumber, manufactureDate, manufacturerName, manufacturerID) {
		this._requireManufacturer(ctx);
		this._require(assetID, 'assetID');
        this._require(engineNumber, 'engineNumber');
        this._require(manufactureDate, 'manufactureDate');
        this._require(manufacturerName, 'manufacturerName');
        this._require(manufacturerID, 'manufacturerID');
        this._require(chassisNumber, 'chassisNumber');
        

		const exists = await this.AssetExists(ctx, assetID);
		if (exists) {
			throw new Error(`The asset ${assetID} already exists`);
		}

		// ==== Create asset object and marshal to JSON ====
		let asset = {
			docType: 'asset',
			assetID: assetID,
			engineNumber: engineNumber,
            manufactureDate: manufactureDate,
            manufacturerName: manufacturerName,
			manufacturerID: manufacturerID,
			chassisNumber:chassisNumber,
			clientIdentity: ctx.clientIdentity.getAttributeValue("clientHash"),
			state : 'UNDER_MANUFACTURER',
		};

		await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(asset)));
		let indexName = 'engine~chassis';
		let IndexKey = await ctx.stub.createCompositeKey(indexName, [asset.engineNumber, asset.chassisNumber]);
		await ctx.stub.putState(IndexKey, Buffer.from('\u0000'));
        return ctx.stub.setEvent("VehicalCreated", Buffer.from(JSON.stringify(asset)));

	}


	// ReadAsset returns the asset stored in the world state with given id.
	async ReadAsset(ctx, id) {
		const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
		if (!assetJSON || assetJSON.length === 0) {
			throw new Error(`Asset ${id} does not exist`);
		}

		return assetJSON.toString();
	}

	// delete - remove a asset key/value pair from state
	async DeleteVehical(ctx, id) {
		this._requireManufacturer(ctx);
		this._require(id, 'assetID');

		let exists = await this.AssetExists(ctx, id);
		if (!exists) {
			throw new Error(`Asset ${id} does not exist`);
		}
		const assetString = await this.ReadAsset(ctx, id);
		const asset = JSON.parse(assetString);
		if(asset.state != "UNDER_MANUFACTURER"){
            throw new Error(`Asset ${id} is not under the Manufacturer state`); 
		}
		if(asset.clientIdentity != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }	


		// to maintain the color~name index, we need to read the asset first and get its color
		let valAsbytes = await ctx.stub.getState(id); // get the asset from chaincode state
		let jsonResp = {};
		if (!valAsbytes) {
			jsonResp.error = `Asset does not exist: ${id}`;
			throw new Error(jsonResp);
		}
		let assetJSON;
		try {
			assetJSON = JSON.parse(valAsbytes.toString());
		} catch (err) {
			jsonResp = {};
			jsonResp.error = `Failed to decode JSON of: ${id}`;
			throw new Error(jsonResp);
		}
		await ctx.stub.deleteState(id); //remove the asset from chaincode state

		// delete the index
		let indexName = 'engine~chassis';
		let IndexKey =  ctx.stub.createCompositeKey(indexName, [assetJSON.engineNumber, assetJSON.chassisNumber]);
		if (!IndexKey) {
			throw new Error(' Failed to create the createCompositeKey');
		}
		//  Delete index entry to state.
		await ctx.stub.deleteState(IndexKey);
		return ctx.stub.setEvent("VehicalDeleted", Buffer.from(JSON.stringify(asset)));
	}

	// transfer to dealer
	async TransferToDealer(ctx, id, dealerID) {
		this._requireManufacturer(ctx);
		this._require(id, 'assetID');
		this._require(dealerID, 'dealerID');

        let assetAsBytes = await ctx.stub.getState(id);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${id} does not exist`);
		}
		

		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + id;
			throw new Error(jsonResp);
		}

		if(assetData.state != "UNDER_MANUFACTURER"){
            throw new Error(`Asset ${id} is not under the Manufacturer state`); 
		}

		if(assetData.clientIdentity != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }
		
		// overwriting original asset with new asset
        
		let updatedAsset = {
			docType : 'asset',
			assetID : assetData.assetID,
			engineNumber : assetData.engineNumber,
            manufactureDate : assetData.manufactureDate,
            manufacturerName : assetData.manufacturerName,
			manufacturerID : assetData.manufacturerID,
			chassisNumber : assetData.chassisNumber,
			clientIdentity: "null",
			state : 'UNDER_DEALER',
			dealerID : dealerID,
		};
        
		await ctx.stub.putState(id, Buffer.from(JSON.stringify(updatedAsset)));
		return ctx.stub.setEvent("VehicalTransfered", Buffer.from(JSON.stringify(updatedAsset)));
	}
	
	// Receive from Manufacturer
	async ReceiveFromManufacturer(ctx, id) {
		this._requireDealer(ctx);
		this._require(id, 'assetID');
		

        let assetAsBytes = await ctx.stub.getState(id);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${id} does not exist`);
		}
		

		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + id;
			throw new Error(jsonResp);
		}

		if(assetData.state != "UNDER_DEALER"){
            throw new Error(`Asset ${id} is not under the Manufacturer state`); 
		}

		if(assetData.dealerID != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }
		
		assetData.clientIdentity = ctx.clientIdentity.getAttributeValue("clientHash");

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(assetData)));
		return ctx.stub.setEvent("VehicalReceived", Buffer.from(JSON.stringify(assetData)));

	}
	// transfer to Customer 
	async TransferToOwner(ctx, assetID, ownerID, ownerName,registrationDate,registrationNumber,numberplate) {
		this._requireDealer(ctx);
		this._require(assetID, 'assetID');
		this._require(ownerID, 'ownerID');
		this._require(ownerName, 'ownerName');
		this._require(registrationDate, 'registrationDate');
		this._require(registrationNumber, 'registrationNumber');
		this._require(numberplate, 'numberplate');


		let assetAsBytes = await ctx.stub.getState(assetID);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${assetID} does not exist`);
		}
		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + assetID;
			throw new Error(jsonResp);
		}
		if(assetData.state != "UNDER_DEALER"){
            throw new Error(`Asset ${id} is not under the Dealer state`); 
		}

		if(assetData.clientIdentity != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }


		let updatedAsset = {
			docType : 'asset',
			assetID : assetData.assetID,
			engineNumber : assetData.engineNumber,
            manufactureDate : assetData.manufactureDate,
            manufacturerName : assetData.manufacturerName,
			manufacturerID : assetData.manufacturerID,
			chassisNumber : assetData.chassisNumber,
			clientIdentity: "null",
			state : 'UNDER_CUSTOMER',
			dealerID : assetData.dealerID,
			ownerID : ownerID,
			ownerName : ownerName,
			registrationDate : registrationDate,
			registrationNumber : registrationNumber,
			numberplate : numberplate,
		};

		await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(updatedAsset)));
		return ctx.stub.setEvent("VehicalTransfered", Buffer.from(JSON.stringify(updatedAsset)));

		
	}


	// Receive from Dealer
	async ReceiveFromDealer(ctx, id) {
		this._requireRegistrar(ctx);
		this._require(id, 'assetID');
        let assetAsBytes = await ctx.stub.getState(id);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${id} does not exist`);
		}
		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + id;
			throw new Error(jsonResp);
		}
		if(assetData.state != "UNDER_CUSTOMER"){
            throw new Error(`Asset ${id} is not under the customer state`); 
		}
		if(assetData.ownerID != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }
		assetData.clientIdentity = ctx.clientIdentity.getAttributeValue("clientHash");

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(assetData)));
		return ctx.stub.setEvent("VehicalReceived", Buffer.from(JSON.stringify(assetData)));

	}


	async ChangeOwner(ctx, assetID, newOwnerID,newOwnerName,registrationDate,registrationNumber) {
		this._requireRegistrar(ctx);
		this._require(assetID, 'assetID');
		this._require(newOwnerName, 'newOwnerName');
		this._require(newOwnerID, 'newOwnerID');
		this._require(registrationDate, 'registrationDate');
		this._require(registrationNumber, 'registrationNumber');


		let assetAsBytes = await ctx.stub.getState(assetID);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${assetID} does not exist`);
		}
		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + assetID;
			throw new Error(jsonResp);
		}

		if(assetData.state != "UNDER_CUSTOMER"){
            throw new Error(`Asset ${id} is not under the customer state`); 
		}

		if(assetData.clientIdentity != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }

		assetData.ownerID = newOwnerID;
		assetData.ownerName = newOwnerName; 
		assetData.registrationNumber = registrationNumber;
		assetData.registrationDate = registrationDate;
		assetData.clientIdentity = "null";

		await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(assetData)));
		return ctx.stub.setEvent("VehicalTransfered", Buffer.from(JSON.stringify(assetData)));
	}

	// Receive from Dealer
	async ReceiveFromOwner(ctx, id) {
		this._requireRegistrar(ctx);
		this._require(id, 'assetID');
        let assetAsBytes = await ctx.stub.getState(id);
		if (!assetAsBytes || !assetAsBytes.toString()) {
			throw new Error(`Asset ${id} does not exist`);
		}
		let assetData = {};
		try {
			assetData = JSON.parse(assetAsBytes.toString()); //unmarshal
		} catch (err) {
			let jsonResp = {};
			jsonResp.error = 'Failed to decode JSON of: ' + id;
			throw new Error(jsonResp);
		}
		if(assetData.state != "UNDER_CUSTOMER"){
            throw new Error(`Asset ${id} is not under the customer state`); 
		}
		if(assetData.ownerID != ctx.clientIdentity.getAttributeValue("clientHash")){
            throw new Error(`Initiator is not the owner`); 
        }
		assetData.clientIdentity = ctx.clientIdentity.getAttributeValue("clientHash");

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(assetData)));
		return ctx.stub.setEvent("VehicalReceived", Buffer.from(JSON.stringify(assetData)));

	}
	
	

	_requireManufacturer(ctx){
        if(ctx.clientIdentity.mspId != 'ManufacturerMSP'){
            throw new Error('This chaincode function can only be called by the Manufacturer Organization');
        }
	}
	_requireDealer(ctx){
        if(ctx.clientIdentity.mspId != 'DealerMSP'){
            throw new Error('This chaincode function can only be called by the Dealer');
        }
    }
    _requireRegistrar(ctx){
        if(ctx.clientIdentity.mspId != 'ExciseMSP'){
            throw new Error('This chaincode function can only be called by the Registrar');
        }
	}
	_require(value, name) {
        if (!value) {
            throw new Error(`Parameter ${name} is missing.`);
        }
    }

	



	// GetAssetsByRange performs a range query based on the start and end keys provided.
	// Read-only function results are not typically submitted to ordering. If the read-only
	// results are submitted to ordering, or if the query is used in an update transaction
	// and submitted to ordering, then the committing peers will re-execute to guarantee that
	// result sets are stable between endorsement time and commit time. The transaction is
	// invalidated by the committing peers if the result set has changed between endorsement
	// time and commit time.
	// Therefore, range queries are a safe option for performing update transactions based on query results.
	async GetAssetsByRange(ctx, startKey, endKey) {

		let resultsIterator = await ctx.stub.getStateByRange(startKey, endKey);
		let results = await this.GetAllResults(resultsIterator, false);

		return JSON.stringify(results);
	}

	// QueryAssetsByOwner queries for assets based on a passed in owner.
	// This is an example of a parameterized query where the query logic is baked into the chaincode,
	// and accepting a single query parameter (owner).
	// Only available on state databases that support rich query (e.g. CouchDB)
	// Example: Parameterized rich query
	async QueryAssetsByOwner(ctx, engineNumber) {
		let queryString = {};
		queryString.selector = {};
		queryString.selector.docType = 'asset';
		queryString.selector.engineNumber = engineNumber;
		return await this.GetQueryResultForQueryString(ctx, JSON.stringify(queryString)); //shim.success(queryResults);
	}

	// Example: Ad hoc rich query
	// QueryAssets uses a query string to perform a query for assets.
	// Query string matching state database syntax is passed in and executed as is.
	// Supports ad hoc queries that can be defined at runtime by the client.
	// If this is not desired, follow the QueryAssetsForOwner example for parameterized queries.
	// Only available on state databases that support rich query (e.g. CouchDB)
	async QueryAssets(ctx, queryString) {
		return await this.GetQueryResultForQueryString(ctx, queryString);
	}

	// GetQueryResultForQueryString executes the passed in query string.
	// Result set is built and returned as a byte array containing the JSON results.
	async GetQueryResultForQueryString(ctx, queryString) {

		let resultsIterator = await ctx.stub.getQueryResult(queryString);
		let results = await this.GetAllResults(resultsIterator, false);

		return JSON.stringify(results);
	}

	// Example: Pagination with Range Query
	// GetAssetsByRangeWithPagination performs a range query based on the start & end key,
	// page size and a bookmark.
	// The number of fetched records will be equal to or lesser than the page size.
	// Paginated range queries are only valid for read only transactions.
	async GetAssetsByRangeWithPagination(ctx, startKey, endKey, pageSize, bookmark) {

		const {iterator, metadata} = await ctx.stub.getStateByRangeWithPagination(startKey, endKey, pageSize, bookmark);
		const results = await this.GetAllResults(iterator, false);

		results.ResponseMetadata = {
			RecordsCount: metadata.fetched_records_count,
			Bookmark: metadata.bookmark,
		};
		return JSON.stringify(results);
	}

	// Example: Pagination with Ad hoc Rich Query
	// QueryAssetsWithPagination uses a query string, page size and a bookmark to perform a query
	// for assets. Query string matching state database syntax is passed in and executed as is.
	// The number of fetched records would be equal to or lesser than the specified page size.
	// Supports ad hoc queries that can be defined at runtime by the client.
	// If this is not desired, follow the QueryAssetsForOwner example for parameterized queries.
	// Only available on state databases that support rich query (e.g. CouchDB)
	// Paginated queries are only valid for read only transactions.
	async QueryAssetsWithPagination(ctx, queryString, pageSize, bookmark) {

		const {iterator, metadata} = await ctx.stub.getQueryResultWithPagination(queryString, pageSize, bookmark);
		const results = await this.GetAllResults(iterator, false);

		results.ResponseMetadata = {
			RecordsCount: metadata.fetched_records_count,
			Bookmark: metadata.bookmark,
		};

		return JSON.stringify(results);
	}

	// GetAssetHistory returns the chain of custody for an asset since issuance.
	async GetAssetHistory(ctx, assetID) {

		let resultsIterator = await ctx.stub.getHistoryForKey(assetID);
		let results = await this.GetAllResults(resultsIterator, true);

		return JSON.stringify(results);
	}

	// AssetExists returns true when asset with given ID exists in world state
	async AssetExists(ctx, assetID) {
		// ==== Check if asset already exists ====
		let assetState = await ctx.stub.getState(assetID);
		return assetState && assetState.length > 0;
	}

	async GetAllResults(iterator, isHistory) {
		let allResults = [];
		let res = await iterator.next();
		while (!res.done) {
			if (res.value && res.value.value.toString()) {
				let jsonRes = {};
				console.log(res.value.value.toString('utf8'));
				if (isHistory && isHistory === true) {
					jsonRes.TxId = res.value.tx_id;
					jsonRes.Timestamp = res.value.timestamp;
					try {
						jsonRes.Value = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Value = res.value.value.toString('utf8');
					}
				} else {
					jsonRes.Key = res.value.key;
					try {
						jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Record = res.value.value.toString('utf8');
					}
				}
				allResults.push(jsonRes);
			}
			res = await iterator.next();
		}
		iterator.close();
		return allResults;
	}


	async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: result.value.key, Record: record });
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }

}

module.exports = Chaincode;
