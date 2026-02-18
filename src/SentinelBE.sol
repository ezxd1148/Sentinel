// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.26;

contract Sentinel {
    struct Evidence { 
        string cid;
        bytes32 logHash;
        uint64 timestamp;
        address reporter;
    }

    
    mapping(bytes32 => Evidence) public receiptimestamp;

    // this is for python listening
    event logAnchored(bytes32 indexed batchId, string cid, bytes32 logHash, uint64 timestamp);
    event ReporterStatusChanged(address reporter, bool isActive);

    address public owner;
    mapping(address => bool) public authorizedReporters;

    // modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");

        _;
    }

    modifier onlyReporter() {
        require(authorizedReporters[msg.sender], "Not authorized sentinel");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedReporters[msg.sender] = true;
    }

    function anchorLog(bytes32 _batchId, string memory _cid, bytes32 _logHash) external onlyReporter {
        require(receiptimestamp[_batchId].timestamp == 0, "Immutable"); //If you see this then immutability is confirmed

        receiptimestamp[_batchId] = Evidence({
            timestamp: uint64(block.timestamp),
            cid: _cid,
            logHash: _logHash,
            reporter: msg.sender
        });

        emit logAnchored(_batchId, _cid, _logHash, uint64(block.timestamp));
    }

    function setReporter(address _reporter, bool _isActive) external onlyOwner {
        authorizedReporters[_reporter] = _isActive;
        emit ReporterStatusChanged(_reporter, _isActive);
    }
}
