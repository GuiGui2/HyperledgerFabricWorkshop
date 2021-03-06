// invoke.js
// sample script using Hyperledger NodeJS SDK to invoke a transaction on an instantiated chaincode
// on a given channel.

// load required modules and define required variables.

let path = require('path');
let fs = require('fs-extra');
let hfc = require('fabric-client');
let utils = require('fabric-client/lib/utils.js');
let Peer = require('fabric-client/lib/Peer.js');
let Orderer = require('fabric-client/lib/Orderer.js');
let console = utils.getLogger('Invoke Chaincode');
let config = require('./config.json');
let util = require ('util');
let txn_id = null;
let client = new hfc();

// Let's configure the nework. For the sake of the example, I am only using one peer.
// Initialization of the environment.
// Create a new channel object using the channelID defined in the config.json file.
// Then add the orderer defined in the config.json orderer array.
let channel = client.newChannel(config.channelID);
let peer = client.newPeer(config.peers[0].peer_url);
channel.addPeer(peer);
channel.addOrderer(new Orderer(config.orderer.orderer_url));

// Retrieve the content of the private key and certificate as defined in the config.json file.
// keyPEM is the private key; certPEM is the public key.
// When the keys will be generated as ECDSA by default, the SDK can retrieve the content
// by itself just by pointing to the files.
// For the time being however, we need to explicitely read the content of the files.
var keyPEM = fs.readFileSync(config.keyPEM).toString();
var certPEM = fs.readFileSync(config.certPEM).toString();
var cryptoSuite = hfc.newCryptoSuite();

// Initialize this cryptoSuite with a new KeyStore, used to store the cryptographic materials.
// The path to the KeyStore is defined in config.json under keyValueStore.
cryptoSuite.setCryptoKeyStore(hfc.newCryptoKeyStore({path: config.keyValueStore }));
client.setCryptoSuite(cryptoSuite);

// Initialize our client to use the CryptoSuite configured above.
return hfc.newDefaultKeyValueStore({
	path: config.keyValueStore
	// Once the keyValueStore has been created, the promised returned object is a KeyValueStore object.
	// This object will be stored and accessed through the store variable.
}).then((store) => {
	 // Configure the client to use the KeyValueStore defined above to persist appliction states.
		client.setStateStore(store);
		        // Rather than using fabric-ca, in this example we use the crypto materials which has been used by
                // the fabric and which was pre-generated. Pass a UserOpts object with the essential required information
                // for this user to interact with the Fabric.
                // privateKeyPEM and signedCertPEM are IdentityPEMs objects containing a string of the content of the files.
                // Should the keys be ECDSA, we could have used IdentityFiles objects, just by pointing to the files rather than passing the content.
		Promise.resolve(client.createUser({
			username: 'Admin',
			mspid: config.mspid,
			cryptoContent: {
				privateKeyPEM: keyPEM,
				signedCertPEM: certPEM
			}
		})).then((admin) => {
			// We wait for the User object to be returned (as admin)
					console.info('Successfully enrolled user \'admin\'');
					client.setUserContext(admin);
                    // then we use it to set the current UserContext for the client.
                    // It means all subsequent interactions with the Fabric will be done using the identity of this user.
			// Here we create a new transaction.
			// First we need a new TransactionID, as below.
			txn_id = client.newTransactionID();
			// Then we need to create the ChaincodeInvokeRequest object.
			var request = {
				chaincodeId: config.chaincodeID,
				chainId: config.channelID,
				txId: txn_id,
				fcn: 'invoke',
				args: ['Key4','Oliv']
			};
			// Now we send the TransactionProposal request to the peers included in this channel for endorsement.
			// The result, a promise for a ProposalResponseObject, will be available through the results object.
			return channel.sendTransactionProposal(request);
		}).then((results) => {
			// The results are a ProposalResponseObject. This object is an array of objects:
			// results[0] is an array of ProposalResponse objects from each endorser peer
			// results[1] is the original Proposal object, which needs to be send to the orderer for ordering.
			var proposalResponses = results[0]; // responses from the endorsing peers
			var proposal = results[1]; // original proposal
			let isProposalGood = false;
			// If we get an answer, which include answers from the peers, and the status is OK
			// then we consider the response to be valid.
			// Additional methods are available to further ensure consistency of the replies.
			if (proposalResponses && proposalResponses[0].response &&
			proposalResponses[0].response.status === 200) {
				isProposalGood = true;
				console.info('Transaction proposal was good');
			} else {
				console.error('Transaction proposal was bad');
			}

			// If Proposal was agreed, then move forward.
			if (isProposalGood) {
				console.info(util.format(
				'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
				proposalResponses[0].response.status, proposalResponses[0].response.message));
				// Create the TransactionRequest object.
				// It contains the responses received from the peers, as well as the original proposal
				var request = {
					proposalResponses: proposalResponses,
					proposal: proposal
				};

			// Now we need a new TransactionID to actually commit the Transaction to the ledger.
			let deployID = txn_id.getTransactionID();
			let promises = [];
			let sendPromise = channel.sendTransaction(request);
			promises.push(sendPromise);

			// For each event source, we create a TransactionEvent to listen to.
			// This will inform the client about the status of the transaction, wether it has been successful
			// or not.
			let eh = channel.newChannelEventHub(peer);
			let txPromise = new Promise((resolve, reject) => {
				console.info('Into the loop')
				let handle = setTimeout(() => {
					eh.unregisterTxEvent(deployID);
					eh.disconnect();
					resolve({event_status : 'TIMEOUT'});
				}, 3000);
				eh.registerTxEvent(deployID.toString(), (tx,code) => {
					console.info("Registered event");
					clearTimeout(handle);

				let return_status = { event_status : code, tx_id : deployID };
				if (code !== 'VALID') {
					console.error('The transaction was invalid, code = ' + code);
					resolve(return_status);
				} else {
					console.info('The transaction has been committed on peer ' + eh.getPeerAddr());
					resolve(return_status);
				}
				}, (err) => {
				reject(new Error('There was an issue with the event hub::' + err));
				},
				{disconnect: true}
			);
			eh.connect();
			});
			promises.push(txPromise);
			return Promise.all(promises);
		} else {
			console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
			throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		}
	}).then((results) => {
		console.info('sending transaction')
		if (results && results[0] && results[0].status === 'SUCCESS') {
			console.info('Successfully sent transaction to the orderer.');
		} else {
			console.error('Failed to order the transaction. Error code: ' + results[0].status);
	}
	if(results && results[1] && results[1].event_status === 'VALID') {
		console.info('Successfully committed the change to the ledger by the peer');
	} else {
		console.info('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
	}
}).catch((err) => {
	console.error('Failed to invoke successfully :: ' + err);
});
});
