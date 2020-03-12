/*
 * Copyright 2018 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

var Constants = require('./constants.js');
var ClientUtils = require('./clientUtils.js');
var createChannel = require('./create-channel.js');
var joinChannel = require('./join-channel.js');
var installCC = require('./install-chaincode.js');
var instantiateCC = require('./instantiate-chaincode.js');
var invokeCC = require('./invoke-chaincode.js');
var queryCC = require('./query-chaincode.js');

var tradeID = 'h87hfj4';

Constants.networkConfig = './config_upgrade.json';	// Use the augmented configuration
Constants.TRANSACTION_ENDORSEMENT_POLICY = Constants.ALL_FIVE_ORG_MEMBERS;	// Use the updated endorsement policy

/////////////////////////////////
// INVOKE AND QUERY OPERATIONS //
/////////////////////////////////

// QUERY: getAccountBalance (Exporter)
queryCC.queryChaincode(Constants.EXPORTER_ORG, Constants.CHAINCODE_VERSION, 'getAccountBalance', [tradeID, 'exporter'], 'Exporter', Constants)
.then((result) => {
	console.log('\n');
	console.log('------------------------------');
	console.log('CHAINCODE QUERY COMPLETE');
	console.log('getAccountBalance VALUE:', result);
	console.log('------------------------------');
	console.log('\n');

	// QUERY: getAccountBalance (Importer)
	return queryCC.queryChaincode(Constants.IMPORTER_ORG, Constants.CHAINCODE_VERSION, 'getAccountBalance', [tradeID, 'importer'], 'Importer', Constants);
}, (err) => {
	console.log('\n');
	console.log('-----------------------------');
	console.log('CHAINCODE QUERY FAILED:', err);
	console.log('getAccountBalance FAILED');
	console.log('-----------------------------');
	console.log('\n');
	process.exit(1);
})
.then((result) => {
	console.log('\n');
	console.log('-------------------------');
	console.log('CHAINCODE QUERY COMPLETE');
	console.log('getAccountBalance VALUE:', result);
	console.log('-------------------------');
	console.log('\n');

	// QUERY: getAccountBalance (Lender)
	return queryCC.queryChaincode(Constants.LENDER_ORG, Constants.CHAINCODE_VERSION, 'getAccountBalance', [tradeID, 'lender'], 'Lender', Constants);
}, (err) => {
	console.log('\n');
	console.log('------------------------');
	console.log('CHAINCODE QUERY FAILED:', err);
	console.log('getAccountBalance FAILED');
	console.log('------------------------');
	console.log('\n');
	process.exit(1);
})
.then((result) => {
	console.log('\n');
	console.log('-------------------------');
	console.log('CHAINCODE QUERY COMPLETE');
	console.log('getAccountBalance VALUE:', result);
	console.log('-------------------------');
	console.log('\n');

	ClientUtils.txEventsCleanup();
}, (err) => {
	console.log('\n');
	console.log('------------------------');
	console.log('CHAINCODE QUERY FAILED:', err);
	console.log('getAccountBalance FAILED');
	console.log('------------------------');
	console.log('\n');
	process.exit(1);
});

process.on('uncaughtException', err => {
	console.error(err);
	joinChannel.joinEventsCleanup();
});

process.on('unhandledRejection', err => {
	console.error(err);
	joinChannel.joinEventsCleanup();
});

process.on('exit', () => {
	joinChannel.joinEventsCleanup();
});
