// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {
    // define state variables
    address public owner;

    // custom request object
    // e.g. name of requestor
    struct Request {
        address requestor;
        string name;
        uint amount;
        string message;
    }

    // custom transaction object
    // e.g. send or receive payment
    struct Transaction {
        string action;
        uint amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    // user information
    struct User {
        string name;
        bool hasName;
    }

    mapping(address => User) users;             // store name for each user
    mapping(address => Request[]) requests;     // store payment requests for each user
    mapping(address => Transaction[]) history;  // store transaction history for each user

    // set owner as deployer of smart contract
    constructor() {
        owner = msg.sender;
    }

    // allow user to add name representing their address
    function addName(string memory _name) public {
        User storage user = users[msg.sender];
        user.name = _name;
        user.hasName = true;
    }

    // allow user to request coins from others
    function createRequest(address user, uint _amount, string memory _message) public {
        Request memory request;
        request.requestor = msg.sender;
        request.amount = _amount;
        request.message = _message;
        if (users[msg.sender].hasName) {
            request.name = users[msg.sender].name;
        }

        // assign newly created request to respondent
        requests[user].push(request);
    }

    // allow user to pay for request
    function payRequest(uint requestIdx) public payable {
        require(requestIdx < requests[msg.sender].length, "No such request");
        Request[] storage myRequests = requests[msg.sender];
        Request storage payableRequest = myRequests[requestIdx];

        // transfer coin to requestor
        uint toPay = payableRequest.amount * 1000000000000000000;
        require(msg.value == toPay, "Incorrect amount");
        payable(payableRequest.requestor).transfer(msg.value);

        // remove executed request
        addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);
        myRequests[requestIdx] = myRequests[myRequests.length - 1];
        myRequests.pop();
    }

    // keep track of transaction history
    function addHistory(address sender, address receiver, uint _amount, string memory _message) private {
        Transaction memory send;
        send.action = "-";
        send.amount = _amount;
        send.message = _message;
        send.otherPartyAddress = receiver;
        if (users[receiver].hasName) {
            send.otherPartyName = users[receiver].name;
        }
        history[sender].push(send);

        Transaction memory newReceive;
        newReceive.action = "+";
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = sender;
        if (users[sender].hasName) {
            newReceive.otherPartyName = users[sender].name;
        }
        history[receiver].push(newReceive);
    }

    // retrieve all requests sent to a user
    function getRequests(address user) public view returns(Request[] memory) {
        return requests[user];
    }

    // retrieve historic transactions user has been apart of
    function getHistory(address user) public view returns(Transaction[] memory) {
        return history[user];
    }

    function getName(address user) public view returns(User memory) {
        return users[user];
    }
}
