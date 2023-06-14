// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/// @title Task1 - Oracle to get weather data(but unfortunatly not applicable yet)
/// @author bahador Ghadamkheir
/// @notice Our aim is to have an oracle smart contract to work on Fantom Opera blockchain
/// To achieving this:
///     1- we first have to run an Oracle node on fantom opera blockchain.
///     2- than we have to create a Job for retreiveing the desired API (weather, sports data, traffic data, etc)
///     3- As there is no active weather(or sports and traffic data on Fantom- or even on Sepolia or Goerli) data feed, 
///         we have to develop an external adapter to interact with API to get/send the desired data.
///     4- Then we need to develop an oracle smart contract(like what we wrote below) and deploy it on Fantom opera(Mainnet or testnet - as we wish)
///     5- Finaly, any other smart contract on  Fantom opera chain, can request data from our oracle smart contract and get results.
contract myOracle is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public data;
    bytes32 private externalJobId; //job id for intracting with chainlink node
    uint256 private oraclePayment; //Link token amout to pay in wei format
    address private oracle; // oracle address

    event RequestUintFulfilled(bytes32 indexed requestId, uint256 indexed Data);

    /// @notice In the constructor we will initialize needed data
    constructor() ConfirmedOwner(msg.sender){
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //link token address
        oracle = 0x6c2e87340Ef6F3b7e21B2304D6C057091814f25E; //oracle address
        externalJobId = "b4bb896b5d9b4dc694e84479563a537a"; //external jobId
        oraclePayment = ((0 * LINK_DIVISIBILITY) / 10); // n * 10**18
    }

    /// @notice requestData function was for interacting with weather oracle.
    /// Although I checked some ways to implement the required functionality(even started to work with graph),
    /// but had not enough time to figure it out
    /// @dev We have to implement oracle weather data on Fantom Opera somehow.
    /// @dev Maybe we be able to run an oracle node on Ethereum goerli testnet, and make a graph on the RequestUintFulfilled event
    /// @dev And after that, we fetch the data, by Apollo or graph client cause they are in different chains(Ethereum goerli and Fantom)
    /// @dev As another solution we may be able to run an oracle node on fantom and create job id and what else is needed. then we can call them here.
    function requestData(/*string memory _apiKey, string memory _city*/) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(externalJobId, address(this), this.fulfillData.selector);
        req.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        req.add("path", "RAW,ETH,USD,VOLUME24HOUR");
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);
        // req.add("get", string(abi.encodePacked("https://api.weatherapi.com/v1/current.json?key=", _apiKey, "&q=_city");
        // req.add("path","current,temp_c");
        sendChainlinkRequestTo(oracle, req, oraclePayment);
    }

    /// @notice fulfillData is not for us to work with.
    /// It will work with oracle contract to bring us desired data
    /// @param _requestId Will be generated with requestData
    /// @param _data Will be returned data
    function fulfillData(bytes32 _requestId, uint256 _data) public recordChainlinkFulfillment(_requestId) {
        data = _data;
        emit RequestUintFulfilled(_requestId, _data);
    }
}