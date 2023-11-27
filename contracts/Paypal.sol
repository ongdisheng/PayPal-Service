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

    mapping(address => User) users;
    mapping(address => Request[]) requests;
    mapping(address => Transaction[]) history;

    // set owner as deployer of smart contract
    constructor() {
        owner = msg.sender;
    }
}
